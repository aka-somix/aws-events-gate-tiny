# Events Gate TINY
*EventsGate "Tiny edition"* is a solution for debugging and monitoring events across all EventBridge buses in your AWS account.  
This stack creates an EventBridge rule that captures all events from a specified event bus (or the default bus if none is specified) and stores them in a dedicated CloudWatch Log Group.  
By centralizing events into a single log group, this solution simplifies troubleshooting, auditing, and debugging workflows across your AWS environment.

#### What's the TINY edition
We are working on a slightly larger product for dinamically monitoring all your event buses with a UI and a custom deployment mdoel. If interested you should check out the [AWS-EVENTS-GATE repo](https://github.com/aka-somix/aws-events-gate)


![Cloud Provider](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonwebservices&style=for-the-badge)

![OpenTofu](https://img.shields.io/badge/IAC-OpenTofu-FFDA18?logo=opentofu&style=for-the-badge)
![CDK](https://img.shields.io/badge/IAC-CDK_Typescript-527FFF?logo=amazonwebservices&style=for-the-badge)
![Cloudformation](https://img.shields.io/badge/IAC-Cloudformation-E7157B?logo=amazonwebservices&style=for-the-badge)

## Launch on your account

The project comes with different options for deployment in your account.

### General Prerequisites
* AWS Account with permissions to create EventBridge and CloudWatch resources.

* AWS CLI installed and configured with credentials.

### Amazon CDK

To launch with cdk you will need additional libraries:
* Node and a package manager (example: **pnpm**)

Furthermore, your account should be bootstrapped for using CDK. [More here](https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html).

Once everything is set, do the following:
1. Go to `cdk` folder
2. Install dependencies
    ```bash
    pnpm i
    ```
1. Run the deploy commmand passing the bus to monitor as context variable:
    ```
    pnpm cdk deploy -c bus=<your_event_bus>
    ```
    If no `bus` is provided then the *default bus* will be used.

#### Applying custom tags
You can apply custom tags to resources by adding a `.tags.json`. For more info [read this doc](./cdk/lib/tags/README.md).

### OpenTofu
To launch with tofu you will need additional libraries:
* Tofu

You can use 

1. Go to `tofu` folder
2. Initialize the backend with:
    ```
    tofu init
    ```
3. Apply using your own `.tfvars` file:
    ```
    tofu apply --var-file="vars.tfvars"
    ```
    You can set the `eventbus_name` in the .tfvars file. If no `bus` is provided then the *default bus* will be used.

#### Applying custom tags
You can apply custom tags to resources by using the `tags` variables in the tfvars
