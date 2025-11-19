# nctl-shift-left

## Why Shift-Left?
Shift left security is crucial as it emphasizes integrating security practices earlier in the software development lifecycle, allowing for proactive identification and mitigation of vulnerabilities and misconfigurations. By addressing security concerns from the outset, organizations can minimize risks, reduce costs associated with fixing issues later in the development process, and ultimately enhance the overall security posture of their products or systems.

## How does the Nirmata CLI (nctl) help?
Integrating Nirmata CLI (`nctl`) into the Continuous Integration (CI) pipeline ensures rapid identification of misconfigurations in Kubernetes manifests, Dockerfiles, and Terraform files, preempting potential issues before they escalate. By providing automated remediations, it streamlines the process of fixing vulnerabilities, thereby reducing delays and ensuring a smoother path to production. This proactive approach enhances the reliability and security of deployments, ultimately accelerating the time-to-market for software releases.

## Nirmata CLI
Learn about the CLI [here](https://docs.nirmata.io/docs/npmk/nctl/).

## Using nctl with GitHub Action
Integrating nctl with GitHub Actions (or other pipelines) adds a critical check in the deployment process. `nctl` scans resources against customizable policies, enabling teams to enforce best practices and security standards. With the flexibility to either fail the pipeline or log issues without blocking it, nctl ensures thorough validation while accommodating varying project requirements.

### Use the GitHub Action
Use the readily available [GitHub Action](https://github.com/marketplace/actions/nctl-scan-installer) to install `nctl`.

### Example Workflows
Checkout the examples in [.github/workflows](./.github/workflows) directory on how to use `nctl` in action!

## Have Questions?
If you have any questions on how to use nctl in your CI pipeline, or if you want to see more features, feel free to create an issue in this repository, or contact us at [support@nirmata.com](support@nirmata.com)
