/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { z } from 'genkit';
import { ai } from './config';


export const SimpleMessageSchema = z.object({
  role: z.string(),
  content: z.string(),
});

export const History = z.object({
  history: z.array(SimpleMessageSchema).optional().default([]),
});

export const Message = z.object({
  role: z.string(),
  content: z.string(),
});



// ChatFlowInput schema
export const ChatFlowInputSchema = z.object({
    history: z.array(SimpleMessageSchema),
    userMessage: z.string(),
  });

ai.defineSchema('ChatFlowInputSchema', ChatFlowInputSchema);


// ChatFlowOutput schema
export const ChatFlowOutputSchema = z.strictObject({
  answer: z.string().optional().default(""),

//   badQuery: z.boolean().optional().default(false),
//   safetyIssue: z.boolean().optional().default(false),
//   quotaIssue: z.boolean().optional().default(false),
  justification: z.string().default("No justification provided"),
});

export type ChatFlowOutput = z.infer<typeof ChatFlowOutputSchema>;
ai.defineSchema('ChatOutputSchema', ChatFlowOutputSchema);


// Schema for the 'activity' class
export const ActivitySchema = z.object({
  activity_id: z.number().int(),
  name: z.string(),
  description: z.string(),
  cost: z.number(), // float in Python translates to number in Zod
  duration_min: z.number().int(),
  duration_max: z.number().int(),
  kid_friendliness_score: z.number().int(),
});

// Schema for the 'activities' class
export const ActivitiesSchema = z.object({
  Activities: z.array(ActivitySchema),
});

export type Activity = z.infer<typeof ActivitySchema>;
export type Activities = z.infer<typeof ActivitiesSchema>;
  
