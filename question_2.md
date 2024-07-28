I. Codebase

Version control system - Git. Web-based git repositories hosting - Gitlab.
At first, I'd have two repos. One is managing infrastructure part and the other application itself. Each project is split between 
two or three main branches. Develop, prod and staging based on requirements and many feature branches. Developers working on code have
limited permission on each repo, ranging from not being able to see the repo up to having abilities to push and merge changes into branches.

II. Dependencies

Since the project is running in Kubernetes, most of the dependencies can be handled inside the container (Dockerfile). During container image build process there might be several more references as in requirements.txt, Gemfile and so on based on the underlying programming languages. Images are built and pushed into container registry in Gitlab, in need package registry can be used as well for non container related programs to store for artifacts.

III. Config

Configuration should not be hard coded into the application, but rather referenced from a configuration file, env file, remote vault. For example, each environment should be separated with their specific database endpoints. The endpoints would be stored as environment variables in Gitlab's CI/CD and referenced for each branch.

IV. Backing services

Loose coupling of backing services such as a database. In case of a problem in database, it should be easy to change URL and point to another service without any application changes.

V. Build, release, run

Each commit is linted, compiled against pre-built base docker images, tested with unit tests as well
as integration tests specific to programs. For example, for Terraform - Terratest could be used, Ansible - ansible-test. 
To make it clear pre-built docker images can be built newly before compiling it's just that application changes are more common 
than underlying environment changes. In case of deploying releases, I'd choose ArgoCD for automatic syncing of the environments. 
ArgoCD should be pointing to packaged Helm applications for easier maintenance. Most of the steps should be performed
without any interference from the developer besides final job run clicks as well as merge review comments.

VI. Processes

Application should not persist any data in internal state, besides short-lived transactional cache. Since the application is stored in a container it's by definition ephemeral, when die application (container) exits, all the data is gone. Application should be easily
replaced.

VII. Port binding

Each application (pod) should be bound to a service. Services bound to ingress route. Previously chosen ArgoCD works well in this case since it's extremely robust, can trigger automated rollouts of pods. Service IP would not change, so not unexpected ip-port changes. In case of software I'd choose Nginx Ingress for highest versatility and multi cloud compatibility, if it's on-premises cluster then MetalLb is a good choice. 

VIII. Concurrency

Similar to processes part, built applications should be independent of their copies, stateless for an easy horizontal scaling without relying on internal state.

IX. Disposability

Containers should be capable of starting in seconds of time, as well as being able to be removed gracefully. Based on application there could be several methods used to reassure graceful shutdowns such as putting unfinished tasks in queue using brokers with a subscriber/publisher model, storing state in a database for example PostgreSQL.

X. Dev/prod parity

Again, since applications are running inside containers, it's not difficult to ensure dev, prod and even local testing environments to be similar. Deployment of containers can take minutes, versioning makes sure everything is the same. Going back to part 4, it's easily testable on different machines, developers can spin up minimized version of the environment with compose or minikube.


XI. Logs

Containers should output logs to default stdout and stderr. Operations team needs to make logs are correctly ingested. I'd choose widely used container logs->Promtail->Loki->Grafana stack.

XII. Admin processes

Application admin processes should ship with application code. In this case I'd choose Kubernetes Jobs, in more advanced environments developing an operator which would be an extension of the app.