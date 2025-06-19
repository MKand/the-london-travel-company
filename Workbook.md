
# Introduction

Welcome to the Obs with GenAI Challenge Lab! In this lab, you'll step into the shoes of a Site Reliability Engineer (SRE) at a bustling startup. Your mission is to leverage Google Cloud Observability tools to ensure the reliability and performance of our your company's MVP application, The London travel Agent. Get ready to dive deep into monitoring, troubleshooting, and optimizing a real-world scenario!

## Get Familiar with the app (15 minutes)

1. Explore the App:

    - Access the MovieGuru application using the URL provided at the start of the lab. (e.g., <http://SomeIP:80>).
    - Start chatting with the app to plan your ideal trip to London.

2. Understand the Architecture:

    - The application is running on GKE. It has two components, the agent (built using Agent Development Kit) and a postgres database with PGVector.
    - The application's telemetry is sent to Google Cloud Platform.

3. Explore the Observability Dashboard in CloudHub:

    - Look for Cloudhub in the search bar of the console.
    @ Afrina We need to add something here 

## Your First Day on the Job: Setting things up (15 minutes)

Welcome to your first day! As you start to get familiar with our projects and how we manage our growing landscape of applications and services, one tool you'll find incredibly useful is **App Hub**.

Think of App Hub as a centralized catalog or inventory for all our applications and the services they're built upon, no matter where or how they're deployed within Google Cloud.

So, why is it so important, especially for someone new like yourself?

- Discoverability & Visibility: Imagine trying to understand a complex system with dozens of microservices, databases, and infrastructure components spread across different projects. App Hub gives us a single place to see what applications exist, who owns them, what services they use (like GKE clusters, Cloud SQL instances, Pub/Sub topics), and even links to their documentation or source code repositories. This will massively speed up your learning process.
- Organization & Governance: It helps us impose order on potential chaos! We can define clear ownership, track business criticality, and ensure that applications adhere to certain standards. This is crucial for managing dependencies, understanding the impact of changes, and ensuring compliance.
- Operational Efficiency: When something goes wrong, or when you need to understand how a particular feature is implemented, App Hub can be your first port of call to identify the relevant components and stakeholders. It helps streamline troubleshooting and operational tasks.
- Collaboration: It provides a shared understanding of our application portfolio across different teams. You can see how your work might connect with or impact other services.

1. Go to AppHub

    - You should see an application called **lta-app** is created. You will notice the metadata associated with the application on the console.
    - If you click on the application, it shows the _services and workloads_ associated with with this application. This list will be empty.
    - We will populate this list. Click on the _Services and Workloads_ tab of AppHub and search for two **workloads** called **agent** and **db**. For each workload:
        - Select the worlkload and click on. the **Register** button.
        - Select the **lta-app** as the application you want to register it to.
        - Finish the steps required to register them. (mark it as it **Mission Critical** and **Production**)
    - You should see 2 new _workloads_ associated with **lta-app**.

2. Explore the individual dashboards associated with each of the workloads of the app.

## Your Second Day on the Job: Troubleshooting MovieGuru (15 minutes)

1. Configure Proactive Monitoring

   - Set up an uptime check for the chat server.  
        - **Target**: Use the backend's health check endpoint: `http://<serverIP>/health`  
        - **Authentication**: None (HTTP)  
   - Optionally, create an alerting policy to notify your email if the uptime check fails.  

2. Simulate a Problematic Deployment: Your development team has released a new version. Let's simulate deploying it.  

   - **Set up your environment in Cloud Shell**:  

    ```sh
    export GCP_PROJECT_ID="YOUR_GCP_PROJECT_ID" # Replace YOUR_GCP_PROJECT_ID  
    gcloud container clusters get-credentials lta-cluster --region us-central1 --project $GCP_PROJECT_ID
    ```

    - Deploy the new version using Helm:  

    ```sh
    helm upgrade london-travel-company-app oci://us-central1-docker.pkg.dev/o11y-movie-guru/london-travel-agency/ltc-observability-lab:1.0.0 \
        --install \
        --namespace ltc \
        --create-namespace \
        --set Config.printHealthStatus="True" 
    ```

3. Observe the Impact:  
   - Wait a few minutes and try accessing the application again. You should find that it's broken.  
   - Check for the alert notification in **Cloud Hub \> Health and Troubleshooting**. If you had configured an alert notificiation, you would have been actively notified.

4. Investigate the Issue:

   - Begin by looking for eventtypes from GKE, by enabling **GKE** from the **annotations** dropdown menu in the **Health and Troubleshooting** page.
   - Utilize the **Investigations** feature in Google Cloud to help diagnose the problem. Refer to these [instructions](https://cloud.google.com/gemini/docs/cloud-assist/investigations#example_of_using_investigations) for guidance.
   - You _may_ be prompted to enable **Cloud Assist** related APIs. Please accept and enable them.

5. Rollback to Restore Service:

    As an SRE, your immediate priority is to minimize user disruption. Therefore, first, rollback to the last known good version to restore service. And then you would fix the underlying issue (we will not be fixing the issue in this lab).
    - To quickly restore service, rollback to the previous stable version:  

    ```sh
        helm rollback london-travel-company-app 1 --namespace ltc
    ```

   - Verify that the application is working again and the metrics on your dashboard stabilize.

## Monitoring User Interactions (15 minutes)

It's crucial to monitor how users interact with your application, and how the LLM responds.

2. Start chatting with the app. We'll examine traces to understand the messages exchanged with the Large Language Models (LLMs). Although the application appears simple, a single user message can trigger multiple LLM calls behind the scenes. Traces help us visualize this complexity. Each user conversation is captured as a trace, detailing every LLM call, including the prompts, user input, and the application's output

    - Go to Google Cloud Trace and find a recent trace of type **ChatFlow**.
    - You will see that there are multiple steps involved before answering a user's chat message.

        - Try to examine the trace and it's spans to identify the prompt used for each step.
        - Click on the __GenAI__ chip of spans to see the components of the trace that are exclusive to GenAI. In fact, recently, there is a [new semantic convention](https://opentelemetry.io/docs/specs/semconv/gen-ai/) for GenAI components which is actively in development. Our application traces utilize this.

## Observability Analytics (10 minutes)
