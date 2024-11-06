#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import 'source-map-support/register';
import { EventsGateTinyStack, resPrefix } from '../lib/cdk-stack';
import { tags } from '../lib/tags/.tags.json';

const app = new cdk.App();
new EventsGateTinyStack(app, 'EventsGateTinyStack', {});

// Statically tag the Project
cdk.Tags.of(app).add("Project", resPrefix);

// Dynamic Tags custom defined.
// For info see cdk/lib/tags/README.md
tags.forEach((t) => cdk.Tags.of(app).add(t.key, t.value));