---
title: GPU Scheduler for De Novo Genome Assembly with Multiple MPI Processes
authors:
- gary
date: "2023-09-13T00:00:00Z"
doi: ""
draft: true

# Schedule page publish date (NOT publication's date).
publishDate: "2017-01-01T00:00:00Z"

# Publication type.
# Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
# 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
# 7 = Thesis; 8 = Patent
publication_types: ["3"]

# Publication name and optional abbreviated publication name.
publication: ""
publication_short: ""

abstract: |2-
  *De Novo* Genome assembly is one of the most important tasks in computational biology.
  ELBA is the state-of-the-art distributed-memory parallel algorithm for overlap detection and layout simplification steps of *De Novo* genome assembly but exists a performance bottleneck in pairwise alignment.

  In this work, we introduce 3 GPU schedulers for ELBA to accommodate multiple MPI processes and multiple GPUs.
  The GPU schedulers enable multiple MPI processes to perform computation on GPUs in a round-robin fashion.
  Both strong and weak scaling experiments show that 3 schedulers are able to significantly improve the performance of baseline while there is a trade-off between parallelism and GPU scheduler overhead.
  For the best performance implementation, the one-to-one scheduler achieves ~7-8x speed-up using 25 MPI processes compared with the baseline vanilla ELBA GPU scheduler.

# Summary. An optional shortened abstract.
summary:

tags:
- High Performance Computing
- Bioinformatics
featured: true

links:
- name: arXiv
  url: https://arxiv.org/abs/2309.07270
url_pdf: 'https://arxiv.org/pdf/2309.07270'
url_code: 'https://github.com/garywei944/ELBA/tree/GPU'
url_dataset: ''
url_poster: 'https://s3.amazonaws.com/garywei.dev/public/posters/ELBA+GPU+poster.pdf'
url_project: ''
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
projects:
- elba_gpu

# Slides (optional).
#   Associate this publication with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides: "example"` references `content/slides/example/index.md`.
#   Otherwise, set `slides: ""`.
slides:
---
