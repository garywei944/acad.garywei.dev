---
title: "GraB-sampler: Optimal Permutation-based SGD Data Sampler for PyTorch"
authors:
- gary
date: "2023-09-28T00:00:00Z"
doi: ""

# Schedule page publish date (NOT publication's date).
publishDate: "2017-01-01T00:00:00Z"

# Publication type.
# Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
# 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
# 7 = Thesis; 8 = Patent
publication_types: ["4"]

# Publication name and optional abbreviated publication name.
publication: ""
publication_short: ""

abstract: |2-
  The online Gradient Balancing (GraB) algorithm, which determines example orderings through the herding problem with per-sample gradients, has been proved as a theoretically optimal solution, consistently outperforming Random Reshuffling.
  Yet, a user-friendly and efficient implementation is absent in the community.

  This work presents *GraB-sampler*, an efficient and easy-to-use Python library designed for seamless integration of the GraB algorithm, additionally proposing three novel variants.
  The best performance result of the *GraB-sampler* reproduces the training loss and test accuracy results with only the cost of 8.7% training time overhead and 0.85% peak GPU memory usage overhead.

# Summary. An optional shortened abstract.
summary:

tags:
- Machine Learning
- Machine Learning Systems
- Cornell Relax ML Lab
featured: true

links:
- name: arXiv
  url: https://arxiv.org/abs/2309.16809
url_pdf: https://arxiv.org/pdf/2309.16809
url_code: 'https://github.com/garywei944/grab-sampler'
url_dataset: ''
url_poster: ''
url_project: 'https://pypi.org/project/grab-sampler/'
url_slides: ''
url_source: ''
url_video: ''

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
image:
  caption:
  focal_point: ""
  preview_only: false

# Associated Projects (optional).
#   Associate this publication with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `internal-project` references `content/project/internal-project/index.md`.
#   Otherwise, set `projects: []`.
projects: []

# Slides (optional).
#   Associate this publication with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides: "example"` references `content/slides/example/index.md`.
#   Otherwise, set `slides: ""`.
slides:
---
