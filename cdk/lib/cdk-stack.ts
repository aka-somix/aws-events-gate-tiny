import * as cdk from 'aws-cdk-lib';
import * as events from 'aws-cdk-lib/aws-events';
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as logs from 'aws-cdk-lib/aws-logs';
import { Construct } from 'constructs';

// Globally defines a prefix for all the resources in the account
export const resPrefix = "EventsGate";

export class EventsGateTinyStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    let eventbusname = this.node.tryGetContext('bus');
    if (eventbusname === undefined) {
      console.warn('❗ - NO EVENTBUS NAME FOUND IN CONTEXT. DEFAULT BUS WILL BE USED');
      eventbusname = 'default';
    }
    else {
      console.info(`🟢 - Using ${eventbusname} Event bus from CONTEXT`);
    }


    // Create log group for storing all events
    const logGroup = new logs.LogGroup(this, `WatchEventsLogGroup-${eventbusname}`, {
      logGroupName: `${resPrefix}/${eventbusname}/watch`,
      retention: logs.RetentionDays.ONE_DAY
    });

    // Define a new EventBridge rule to capture all events
    const allEventsRule = new events.Rule(this, `AllEventsRule-${eventbusname}`, {
      ruleName: `${resPrefix}WatchBusRule`,
      eventPattern: {
        account: [this.account]     // Captures all the events
      },
      eventBus: events.EventBus.fromEventBusName(this, `EventBusToWatch-${eventbusname}`, eventbusname)
    });

    // Link the rule to the cloudwatch group
    allEventsRule.addTarget(new targets.CloudWatchLogGroup(
      logGroup,
      {
        maxEventAge: cdk.Duration.hours(1)
      }));
  }
}
