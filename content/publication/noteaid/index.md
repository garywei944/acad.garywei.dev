---
title: "README: Bridging Medical Jargon and Lay Understanding through Expert Annotations and Data-Centric NLP"
authors:
- Zonghai Yao
- Nandyala Siddharth Kantu
- gary
- Hieu Tran
- Zhangqi Duan
- Sunjae Kwon
- Zhichao Yang
- Hong Yu
author_notes:
- "Equal contribution"
- "Equal contribution"
date: "2023-12-15T00:00:00Z"
doi: ""

# Schedule page publish date (NOT publication's date).
publishDate: "2017-01-01T00:00:00Z"

# Publication type.
# Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
# 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
# 7 = Thesis; 8 = Patent
publication_types: ["1"]

# Publication name and optional abbreviated publication name.
publication: "2024 Annual Conference of the North American Chapter of the Association for Computational Linguistics"
publication_short: "NAACL 2024"

abstract: |2-
  The growing patient access to Electronic Health Records (EHRs) necessitates tools that aid in demystifying medical jargon.
  This paper extends the work on NoteAid, an NLP system designed to improve patient understanding of EHR notes by linking clinical terms to lay language.
  We address the critical gap left by the previous systems, which lack comprehensiveness in their lay definitions for medical jargon.
  Our study introduces the README dataset, an expert-annotated collection of medical terms paired with lay definitions tailored for a 4th-7th grade reading level.
  We detail the development of a novel data-centric pipeline that leverages a Human-AI-in-the-loop paradigm to refine the README dataset, which involved rounds of AI-assisted data cleaning, augmentation, and validation to ensure high quality.

  By comparing different versions of the README dataset, we show that AI-examined high-quality subsets lead to superior performance in NLP models.
  Additionally, we explore AI-synthetic data augmentation strategies and their efficacy when expert-annotated data is limited.
  Our findings have significant implications for the future of patient-centric EHR interfaces, demonstrating that a focus on data quality substantially enhances the utility of NLP tools in real-world healthcare communication.

# Summary. An optional shortened abstract.
summary:

tags:
- Machine Learning
- Natural Language Processing
- Biomedical
- UMass BioNLP Lab
featured: false

links:
url_pdf:
url_code:
url_dataset: ''
url_poster: ''
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
projects: []

# Slides (optional).
#   Associate this publication with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides: "example"` references `content/slides/example/index.md`.
#   Otherwise, set `slides: ""`.
slides:
---

## Disclaimer

Submitted to ACL Rolling Review.
This work is done when I was undergraduate research assistant at [UMass BioNLP Lab](https://bionlp.umassmed.edu/).
