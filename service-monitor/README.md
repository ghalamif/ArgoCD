# Prometheus and Argocd
## Introduction:
Prometheus, a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts when specified conditions are observed.

The features that distinguish Prometheus from other metrics and monitoring systems are:

A **multi-dimensional** data model (time series defined by metric name and set of key/value dimensions)
PromQL, a **powerful and flexible query language** to leverage this dimensionality
No dependency on distributed storage; single server nodes are autonomous
An HTTP **pull model** for time series collection
**Pushing time series** is supported via an intermediary gateway for batch jobs
Targets are discovered via **service discovery** or **static configuration**
Multiple modes of **graphing and dashboarding support**
Support for hierarchical and horizontal federation

## Architecture
![s](https://github.com/prometheus/prometheus/blob/main/documentation/images/architecture.svg)

## How to Install
I refcommand you to install it via Helm chart
