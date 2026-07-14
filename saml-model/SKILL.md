---
name: saml-model
description: >
  Selects what models to use for various types of work.
---

# Task

For task agents, use the following models in order (if the first model does not exist, try the next):

- Claude Sonnet 4.6
- GPT-5.4 mini

# All other

For all other models (research, review, general purpose, ...etc), use the following models in order (if the first model does not exist, try the next):

- Claude Opus 4.6
- Claude Sonnet 4.6

# If model cannot be found

If no models are found, use the current model set for the agent.
