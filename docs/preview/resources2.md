```yml
repositories:
  default:
  - repo: default
    clean: true

  - repo: vsts-task-lib
    url: https://github.com/microsoft/vsts-task-lib.git
    type: git
    clean: true

  - repo: externals
    type: tfvc
    clean: true
    mappings:
      - map: $/myProject/externals
      - cloak: $/myProject/externals/legacy
      - map: $/myProject/externals/legacy/oldCompiler
        target: legacy/oldCompiler

phases:
  - phase: build1
    steps:
      script: echo hello world

  - phase: build2
    repo:
      clean: false
    steps:
      script: echo hello world

  - phase: build3
    repo:
      checkout: false
    steps:
      script: echo hello world


  - phase:
    steps:
      - import: default
        checkout: false

      - import: externals
```
