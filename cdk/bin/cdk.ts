#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import 'source-map-support/register';
import { EventsGateTinyStack, resPrefix } from '../lib/cdk-stack';
import { tags } from '../lib/tags/.tags.json';
import { createHash } from 'crypto';


const stackNameGenerator = (app: cdk.App) => {
    const eventbusname = app.node.tryGetContext('bus') ?? 'default';

    const hash = createHash('md5');
    hash.update(eventbusname);
    const hashFromBus = hash.digest('hex').substring(0, 8);

    return `EventsGateTinyStack${hashFromBus}`
}

const app = new cdk.App();
new EventsGateTinyStack(app, stackNameGenerator(app), {});

// Statically tag the Project
cdk.Tags.of(app).add("Project", resPrefix);

// Dynamic Tags custom defined.
// For info see cdk/lib/tags/README.md
tags.forEach((t) => cdk.Tags.of(app).add(t.key, t.value));