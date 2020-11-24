![GitHub Actions status](https://github.com/git-qfzhang/git-qfzhang/alibaba-fc-build-action/workflows/Check/badge.svg)
[![License](https://img.shields.io/github/license/git-qfzhang/git-qfzhang/alibaba-fc-build-action.svg)](https://github.com/git-qfzhang/git-qfzhang/alibaba-fc-build-action/blob/master/LICENSE)

# Alibaba Function Computer Build Action For Github Actions

Github action for building artifacts for compiled language runtime or installing dependencies for interpreted language runtime. 

<!-- toc -->

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Input variables](#input-variables)
- [License Summary](#license-summary)

<!-- tocstop -->

## Prerequisites

You should be familiar with Alibaba FC and Serverless-Devs FC Component. For more information, see:

* "[Alibaba FC](https://help.aliyun.com/document_detail/52895.html?spm=a2c4g.11186623.6.541.7678c030BEWawt)"
* "[Serverless-Devs FC Component](https://github.com/Serverless-Devs-Awesome/fc-alibaba-component/)"

## Usage

Currently, [Alibaba Fcuntion Computer](https://help.aliyun.com/document_detail/74712.html?spm=a2c4g.11174283.6.563.20685212c2S6QB) supports the following programming languages:

| Language | Type |
| ---- | ---- |
| Nodejs | Interpreted |
| Python | Interpreted |
| PHP | Interpreted |
| Java | Compiled |
| C# | Compiled |

If you want to build the target [projects]((https://github.com/Serverless-Devs/docs/blob/master/docs/en/tool/yaml_format.md)), you should input these projects seperated by space to `projects` varibale as follows:

```yaml
    name: Check

    on:
      push:
        branches: [main]
      pull_request:
        branches: [main]

    jobs:
      build:
        name: Build target projects
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2

        - name: Initializing Serverless-Devs
          uses: git-qfzhang/Serverless-Devs-Initialization-Action@main
          with:
            provider: alibaba
            AccessKeyID: ${{ secrets.ALIYUN_ACCESS_KEY_ID }}
            AccessKeySecret: ${{ secrets.ALIYUN_ACCESS_KEY_SECRET }}
            AccountID: ${{ secrets.ALIYUN_ACCOUNT_ID }}

        - name: Building
          uses: git-qfzhang/alibaba-fc-build-action@main
          with: 
            working_directory: ./test
            projects: 'ServerlessDevsNode10 ServerlessDevsJava8'
```

You should ignore `projects` variable or input `*` to `projects` varibale when building all projects:

```yaml
    name: build fc function

    on:
      push:
        branches: [main]
      pull_request:
        branches: [main]

    jobs:
      build:
        name: Build all projects
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2

        - name: Initializing Serverless-Devs
          uses: git-qfzhang/Serverless-Devs-Initialization-Action@main
          with:
            provider: alibaba
            AccessKeyID: ${{ secrets.ALIYUN_ACCESS_KEY_ID }}
            AccessKeySecret: ${{ secrets.ALIYUN_ACCESS_KEY_SECRET }}
            AccountID: ${{ secrets.ALIYUN_ACCOUNT_ID }}

        - name: Building
          uses: git-qfzhang/alibaba-fc-build-action@main
          with: 
            working_directory: ./test
```

The application of alibaba-fc-build-action can refer to [Serverless CI/CD](https://github.com/git-qfzhang/Serverless-CI-CD/tree/dev/src).

`git-qfzhang/Serverless-Devs-Initialization-Action` is the precondition of the building action, more information can refer to [here](https://github.com/git-qfzhang/Serverless-Devs-Initialization-Action/blob/main/README.md).

## Input variables

See [action.yml](action.yml) for the full documentation for this action's inputs.

* working_directory - the directory containing template.yml/template.yaml which could refer to [here](https://github.com/Serverless-Devs-Awesome/fc-alibaba-component/).

* projects - target projects which are delimited by space. The default * represents all projects.

## License Summary

This code is made available under the MIT license.