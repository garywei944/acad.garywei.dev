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
- README Annotation Team
- Hong Yu
date: "2023-12-24T00:00:00Z"
doi: ""

# Schedule page publish date (NOT publication's date).
publishDate: "2017-01-01T00:00:00Z"

# Publication type.
# Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
# 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
# 7 = Thesis; 8 = Patent
publication_types: ["1"]

# Publication name and optional abbreviated publication name.
publication: "Under Review"
publication_short: 

abstract: |2-
  The advancement in healthcare has shifted focus toward patient-centric approaches, particularly in self-care and patient education, facilitated by access to Electronic Health Records (EHR). However, medical jargon in EHRs poses significant challenges in patient comprehension. To address this, we introduce a new task of automatically generating lay definitions, aiming to simplify complex medical terms into patient-friendly lay language. We first created the README dataset, an extensive collection of over 20,000 unique medical terms and 300,000 mentions, each offering context-aware lay definitions manually annotated by domain experts. We have also engineered a data-centric Human-AI pipeline that synergizes data filtering, augmentation, and selection to improve data quality. We then used README as the training data for models and leveraged a Retrieval-Augmented Generation (RAG) method to reduce hallucinations and improve the quality of model outputs. Our extensive automatic and human evaluations demonstrate that open-source mobile-friendly models, when fine-tuned with high-quality data, are capable of matching or even surpassing the performance of state-of-the-art closed-source large language models like ChatGPT. This research represents a significant stride in closing the knowledge gap in patient education and advancing patient-centric healthcare solutions.


# Summary. An optional shortened abstract.
summary:

tags:
- Machine Learning
- Natural Language Processing
- Biomedical
- UMass BioNLP Lab
featured: false

links:
- name: arXiv
  url: https://arxiv.org/abs/2312.15561
url_pdf: 'https://arxiv.org/pdf/2312.15561.pdf'
url_code: 'https://github.com/seasonyao/NoteAid-README'
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
