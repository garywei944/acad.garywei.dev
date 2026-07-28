#!/bin/bash
set -euo pipefail

echo "Entry point script running"

CONFIG_FILE=_config.yml
DOCKER_DESTINATION=/tmp/_site
JEKYLL_PID=""

# Function to manage Gemfile.lock
manage_gemfile_lock() {
    git config --global --add safe.directory /srv/jekyll
    if command -v git &> /dev/null && [ -f Gemfile.lock ]; then
        if git ls-files --error-unmatch Gemfile.lock &> /dev/null; then
            echo "Gemfile.lock is tracked by git, keeping it intact"
            git restore Gemfile.lock 2>/dev/null || true
        else
            echo "Gemfile.lock is not tracked by git, removing it"
            rm Gemfile.lock
        fi
    fi
}

ensure_bundle_deps() {
    if bundle check >/dev/null 2>&1; then
        echo "Bundler dependencies already satisfied"
        return
    fi

    echo "Installing missing bundler dependencies"
    bundle install --jobs 4 --retry 3
}

stop_jekyll() {
    if [ -n "$JEKYLL_PID" ] && kill -0 "$JEKYLL_PID" 2>/dev/null; then
        kill -TERM "$JEKYLL_PID" 2>/dev/null || true
        for _ in $(seq 1 50); do
            if ! kill -0 "$JEKYLL_PID" 2>/dev/null; then
                break
            fi
            sleep 0.1
        done
        if kill -0 "$JEKYLL_PID" 2>/dev/null; then
            kill -KILL "$JEKYLL_PID" 2>/dev/null || true
        fi
        wait "$JEKYLL_PID" 2>/dev/null || true
    fi
    JEKYLL_PID=""
}

cleanup() {
    stop_jekyll
}

trap cleanup EXIT
trap 'exit 0' INT TERM

start_jekyll() {
    manage_gemfile_lock
    ensure_bundle_deps
    mkdir -p "$DOCKER_DESTINATION"
    bundle exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling --disable-disk-cache --destination "$DOCKER_DESTINATION" --config "$CONFIG_FILE" &
    JEKYLL_PID=$!
}

start_jekyll

while true; do
    if ! kill -0 "$JEKYLL_PID" 2>/dev/null; then
        jekyll_status=0
        wait "$JEKYLL_PID" || jekyll_status=$?
        JEKYLL_PID=""
        exit "$jekyll_status"
    fi

    if inotifywait -q -t 1 -e modify,move,create,delete "$CONFIG_FILE"; then
        echo "Change detected to $CONFIG_FILE, restarting Jekyll"
        stop_jekyll
        start_jekyll
    else
        inotify_status=$?
        if [ "$inotify_status" -ne 2 ]; then
            exit "$inotify_status"
        fi
    fi
done
