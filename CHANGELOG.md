# Changelog

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).
This changelog is generated automatically based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## [0.6.0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.5.0...v0.6.0) (2023-06-07)


### Features

* adds metadata generation for the solution ([#81](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/81)) ([7364389](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/736438949814f18399985e12b70a3c36e3d580aa))
* implement fast-follow placeholder website for firebase ([#75](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/75)) ([3c6704c](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/3c6704c93f337a7b449dca16ce330dbde0c6220e))
* support multiple firebase sites ([#58](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/58)) ([8110284](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/8110284f544b17cff7c745d3b31200dd6100a3e3))
* update avocano to v1.8.1 ([#250](https://github.com/GoogleCloudPlatform/avocano/pull/250))


### Bug Fixes

* **deps:** update go modules ([#77](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/77)) ([53cc564](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/53cc56430c96bdb56d0bc7f54ea447625ceb2c69))
* **deps:** update go modules ([#86](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/86)) ([2df6c66](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/2df6c661f395d4ff4530b1f11fee632dcd65ea04))
* **deps:** update module github.com/gruntwork-io/terratest to v0.42.0 ([#80](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/80)) ([fd32492](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/fd3249276c1ecf7eeb0bc99144a8fe4bd2ce65c2))
* restore missing dependencies ([#84](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/84)) ([3fbdd5e](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/3fbdd5e22c222595e01f45973aebf08d6cf05140))

## [0.5.0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.4.1...v0.5.0) (2023-05-05)


### Features

* run jobs on every tf apply ([#46](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/46)) ([8b31d53](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/8b31d5375a4f32055cf0273b85175fa3401c57b5))
* update Avocano from v1.4.1 to v1.5.0 ([#46](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/46)) ([8b31d53](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/8b31d5375a4f32055cf0273b85175fa3401c57b5))
* update Avocano to version 1.7.0 ([#74](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/74)) ([bf3aa56](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/bf3aa560e4094dbc6c4d53f649b98a8bf26802aa))
* update to Avocano from v1.5.0 to v1.6.0 ([#53](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/53)) ([a95f17a](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/a95f17a134aeb6794993aedd4f6cb1661cc2dea6))


### Bug Fixes

* **deps:** update module github.com/gruntwork-io/terratest to v0.41.20 ([#72](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/72)) ([3245e4a](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/3245e4ab9ee12eb955aedc1ebc0eddd150d0d98c))
* **deps:** update module github.com/gruntwork-io/terratest to v0.41.23 ([#73](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/73)) ([b0e9761](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/b0e976188f86045ffe88a9839b4c0f59cf3d3fb1))
* ensure APIs are enabled before provisioning compute resources ([#68](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/68)) ([791f6e1](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/791f6e13978f26bdf7b35a0de85c7a719049f6fd))
* make sure subnet is uniquely named ([#61](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/61)) ([490d4b0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/490d4b06e511c52b93d577d7a7cac2b2316fd7f8))
* prevent website not found errors after firebase deploy completes ([#69](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/69)) ([6d34e1e](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/6d34e1ea9144c9947737994f324b6d270efe3662))
* remove startup probe ([#71](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/71)) ([7c79494](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/7c79494487510db70f811ad76c6d21752105b47f))
* update gce-vpc to use random suffix ([#56](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/56)) ([518d795](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/518d795eb59f4d7ca037a2816f9611551863a37d))
* use DJANGO_SUPERUSER_PASSWORD with setup job ([#53](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/53)) ([a95f17a](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/a95f17a134aeb6794993aedd4f6cb1661cc2dea6))
* use google_project_iam_member to manage IAM permissions ([#54](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/54)) ([9d0de20](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/9d0de20a794b7c041c191397c638a584bcbf606a))

## [0.4.1](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.4.0...v0.4.1) (2023-04-05)


### Bug Fixes

* add API warmup curl in postdeployment.tf ([#42](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/42)) ([2e0888c](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/2e0888c4f92d5117a172ec37bf5125c0119de5dd))

## [0.4.0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.3.2...v0.4.0) (2023-04-04)


### Features

* update avocano to 1.4.1 ([#39](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/39)) ([8e3799d](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/8e3799db1aa5562047a8491eee1dc6a0e1b07e40))

## [0.3.2](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.3.1...v0.3.2) (2023-04-03)


### Bug Fixes

* add neos_toc_url for ecommerce-serverless ([#37](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/37)) ([50c7552](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/50c75523f22280fe4705a0664383695922a1fe01))
* ensure storage is deployed to selected region ([#30](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/30)) ([06cdfe3](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/06cdfe30b64883157fe3d3fa5799d18eae21c198))

## [0.3.1](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.3.0...v0.3.1) (2023-03-30)


### Bug Fixes

* correct neos url ([#34](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/34)) ([7b41126](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/7b41126ab8ec89d337097275235806809c53abdf))

## [0.3.0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.2.0...v0.3.0) (2023-03-29)


### Features

* add health checks and opentelemetry trace configuration ([#27](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/27)) ([4db3641](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/4db36416a4954e3c976ab61158ed399a69616728))
* **infra:** migrate server to cloud run v2 resource ([#26](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/26)) ([d77b1cf](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/d77b1cf085556b4a1f2269a2424b786c44944c12))
* fix: Update outputs.tf to include neos toc tutorial url ([#29](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/29)) ([58f4dfd](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/58f4dfdce61bf400d1f24cd2d00753cec4bc226b))

## [0.2.0](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.1.4...v0.2.0) (2023-03-21)


### Features

* pin the server/client image version ([#24](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/24)) ([42f7a57](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/42f7a57f3352ae370ff45314ee09b9718cb75ea6))

## [0.1.4](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.1.3...v0.1.4) (2023-03-04)


### Bug Fixes

* **deps:** update module github.com/stretchr/testify to v1.8.2 ([#19](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/19)) ([e5e6f68](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/e5e6f683ae30f1c57eb3d4f2cd608e39c67f64a4))

## [0.1.3](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.1.2...v0.1.3) (2023-03-03)


### Bug Fixes

* retry on Cloud Run job execution ([#18](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/issues/18)) ([097efe5](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/097efe5997bc3fd85bfd258661230a77c74686e2))

## [0.1.2](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.1.1...v0.1.2) (2023-03-02)


### Bug Fixes

* update infra/README.md ([3b950d6](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/3b950d6f0a61d39e146f27fecddb3dece4a0fdec))

## [0.1.1](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/compare/v0.1.0...v0.1.1) (2023-03-01)


### Bug Fixes

* Ensure on deletion, bucket contents also destroyed ([9adfb1b](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/9adfb1b15852b7ba6477bb10030e34e8c90c4004))

## 0.1.0 (2023-03-01)


### Bug Fixes

* add custom vpc for gce init ([11102dc](https://github.com/GoogleCloudPlatform/terraform-dynamic-python-webapp/commit/11102dc029197c71ab56148c75ce03ea76c46e37))

## [0.1.0](https://github.com/terraform-google-modules/terraform-dynamic-python-webapp/releases/tag/v0.1.0) - 20XX-YY-ZZ

### Features

- Initial release

[0.1.0]: https://github.com/terraform-google-modules/terraform-dynamic-python-webapp/releases/tag/v0.1.0
