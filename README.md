# Azure SQL DB, Langchain, LangGraph and Chainlit

This repository showcases a simple AI-powered chat application built using Python and leveraging the power of[Chainlit](https://docs.chainlit.io/get-started/overview) and [LangChain](https://www.langchain.com/). The project, which stems from the innovative demonstrations presented at the [#RAGHack](https://github.com/microsoft/RAG_Hack) event, allows users to submit chat requests to retrieve information about event sessions and speakers using [vector similarity search with Azure SQL and Azure OpenAI](https://learn.microsoft.com/en-us/samples/azure-samples/azure-sql-db-openai/azure-sql-db-openai/). For additional insights and to access the recording, visit the discussion: [RAG on Azure SQL Server](https://github.com/microsoft/RAG_Hack/discussions/53).

The application provides two implementations of the RAG process:

1. A straightforward version using LangChain (`app.py`)
2. A dynamic approach using LangGraph (`app-langgraph.py`)

The app demonstrates how Azure SQL Database and the Retrieval-Augmented Generation (RAG) pattern can enhance data retrieval and utilization in a copilot chat application.

## Architecture

![Application architecture](./_assets/architecture.png)

The Python application leverages Chainlit and LangChain to send search requests to an Azure SQL database. Stored procedures utilize Azure OpenAI to embed the incoming query and compare it to vector embeddings stored in the database to find similar sessions and speakers.

The native [Vector data type](https://learn.microsoft.com/sql/t-sql/data-types/vector-data-type?view=azuresqldb-current&tabs=csharp-sample) is used to store embeddings containing speaker and session details directly in those tables. The `[web].[get_embedding]` stored procedure in Azure SQL handles embedding generation using the `sp_invoke_external_rest_endpoint` procedure to make calls to Azure OpenAI. Optionally, an Azure Function App can be triggered when changes occur in designated SQL tables. The function then calls Azure OpenAI directly to generate embeddings for the inserted or updated records and insert them into the database.

The application is composed of three main Azure components:

- [Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/sql-database-paas-overview?view=azuresql): The Azure SQL database that stores application data.
- [Azure Open AI](https://learn.microsoft.com/azure/ai-services/openai/): Hosts the language models for generating embeddings and completions.
- [Azure Functions](https://learn.microsoft.com/azure/azure-functions/functions-overview?pivots=programming-language-csharp): The serverless function to automate the process of generating the embeddings (this is optional for this sample)

The solution requires an Azure SQL database and Azure OpenAI service for vector embedding and chat completions, but it can be run locally or in Azure. Running the complete solution in Azure requires the Chainlit application to be containerized and deployed to Azure using one of the available options for hosting containerized applications, such as Azure Container Apps or Azure Kubernetes Service (AKS). However, the steps for that are not covered in the instructions for this solution.

## Try It Out

The fastest way to try out the sample application is to follow the instructions below for creating a GitHub Codespace and deploying the required Azure resources by running the [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview?tabs=windows) template and Bicep scripts included in the repo.

You can also choose to deploy resources manually, or use existing resources, in your Azure subscription.

## Set Up Your Development Environment

The recommend method for setting up a development environment is to use **GitHub Codespaces**, which provides a fast and fully preconfigured workspace with minimal setup required. However, if you don't have access to codespaces or would rather work locally, this section also includes basic instructions to help you configure **VS Code** for a smooth development experience.

### Create a Codespace

GitHub Codespaces allows you to start developing in a secure, configurable, and dedicated environment based on a development container specification. Development containers, or dev containers, are Docker containers that are specifically configured to provide a fully featured development environment. Whenever you work in a codespace, you are using a dev container on a virtual machine.

The solution includes a preconfigured development container that you can use to set up a codespace on GitHub. You can view the dev container specification for this project in the `.devcontainer/devcontainer.json` file in the repo.

To set up a codespace:

1. Navigate to the [Azure SQL DB LangChain RAG with Chainlit repo](https://aka.ms/azuresqldb-rag-langchain-chainlit).
2. Fork the repo.
3. On your fork, create a codespace by selecting **Code --> Codespaces --> Create codespace...**.
4. It will take about 10 minutes for the codespace to be created and set up.

Once your codespace has been created, you will complete the remaining tasks from the VS Code instance within your codespace environment. You can jump to the [Provision Azure Resources](#provision-azure-resources) section below.

### Use Your Local Machine

If you do not have access to GitHub Codespaces, or prefer to use your local machine, follow the instructions below to configure a development environment on your local machine using Visual Studio Code and Python.

Install the following:

1. [Visual Studio Code](https://code.visualstudio.com/download) with the following extensions:

   - [Azure Functions](https://marketplace.visualstudio.com/items/?itemName=ms-azuretools.vscode-azurefunctions)
   - [Azure Account](https://marketplace.visualstudio.com/items/?itemName=ms-vscode.azure-account)
   - [Azure Resources](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureresourcegroups)
   - [Bicep](https://marketplace.visualstudio.com/items/?itemName=ms-azuretools.vscode-bicep)
   - [Docker](https://marketplace.visualstudio.com/items/?itemName=ms-azuretools.vscode-docker)
   - [C#](https://marketplace.visualstudio.com/items/?itemName=ms-dotnettools.csharp)
   - [C# Dev Kit](https://marketplace.visualstudio.com/items/?itemName=ms-dotnettools.csdevkit)
   - [.NET Install Tool](https://marketplace.visualstudio.com/items/?itemName=ms-dotnettools.vscode-dotnet-runtime)
   - [Python](https://marketplace.visualstudio.com/items/?itemName=ms-python.python)
   - [Python Debugger](https://marketplace.visualstudio.com/items/?itemName=ms-python.debugpy)
   - [MSSQL](https://marketplace.visualstudio.com/items/?itemName=ms-mssql.mssql)

2. [Azure Function Core Tools](https://learn.microsoft.com/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp)

3. [Python 3.11](https://www.python.org/downloads/release/python-31112/)

After installing the above tools, clone the [Azure SQL DB LangChain RAG with Chainlit repo](https://aka.ms/azuresqldb-rag-langchain-chainlit) and open it in VS Code.

## Provision Azure Resources

The solution requires an Azure SQL database and Azure OpenAI services. You can also optionally deploy an Azure Function App to handle generating embeddings for data. You can use the provided Azure Developer CLI template to deploy new resources into your Azure subscription, manually deploy the resources, or use existing services.

### Using Azure Developer CLI Template

The template provided in this repo will deploy a small Azure SQL database and an Azure OpenAI service with the required `gpt-4o` and `text-embedding-ada-002` models. It can also be used to optionally deploy an Azure Function App.

Azure Developer CLI templates are run using the `azd up` command from an integrated terminal window in VS Code. Follow the steps below to execute the template and provision the necessary Azure resources:

1. Open a new terminal windows in VS Code.

2. Sign into Azure using the Azure CLI:

    ```bash
    az login
    ```

3. Sign into the Azure Developer CLI:

    ```bash
    azd auth login
    ```

4. Run the deployment command to execute the included Bicep scripts:

    ```bash
    azd up
    ```

5. The `azd up` command will prompt you for several values after issuing the command. At the terminal prompt, provide the requested information to provision and deploy the Azure resources:

    - Enter an environment name, such as "dev" or "test."
    - Select the subscription you want to use for the resources for this solution.
    - Indicate if you want to deploy an Azure Function App.

      > Deploying an Azure Function app is an optional component of the solution. You can run and test the function in your codespace, or locally, if you prefer to not deploy the function to Azure.

    - Select the Azure region into which you would like to deploy the resources for this solution.

      > **NOTE**: The Bicep script will deploy an Azure OpenAI service and create deployments for the `gpt-4o` and `text-embedding-ada-002` models. To ensure the deployment succeeds, review the [regional availability for Azure OpenAI models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=standard%2Cstandard-chat-completions#models-by-deployment-type) before selecting a region. You should also verify you have 10,000 TPMs of available capacity in the region for each model.

    - Enter a resource group name, such as `rg-azure-sql-rag-app`.
    - Enter a strong password for the Azure SQL Admin account. Note, this is needed to deploy the database, but the Bicep script will configure the SQL Server and database to use Microsoft Entra ID authentication only.

6. Skip to [Deploy Sample Database](#deploy-sample-database) below.

### Manually Provision Resources

You can also deploy the required Azure resources manually by using the Azure CLI or Azure portal to create an Azure SQL database and Azure OpenAI service. If you would like to deploy the sample function, you must also provision an Azure Function App.

For the database, ensure you add the IP address of your local machine to the SQL Server's firewall.

To run the solution, you must deploy two models to your Azure Open AI service:

1. A text embedding model for generating embeddings (*text-embedding-ada-002* model recommended)
2. A chat model for handling the chat (*gpt-4o* recommended)

You can use the Azure AI Foundry portal to deploy the required models into your Azure OpenAI service. The two models are assumed to be deployed with the following names:

- Chat model: `gpt-4o`
- Embedding model: `text-embedding-ada-002`

Once your resources are deployed, you can skip to [Deploy Sample Database](#deploy-sample-database) below.

### Use Existing Azure Resources

It is also possible to leverage an existing Azure SQL database and Azure OpenAI service in your subscription to run the solution. Using that approach, you must deploy the sample database onto your Azure SQL server and ensure the correct models are deployed into your Azure OpenAI service.

To deploy the database, you must create a new database or use an existing database and deploy the sample database into that.

Ensure your Azure Open AI service has two models deployed, one for generating embeddings (*text-embedding-ada-002* model recommended) and one for handling the chat (*gpt-4o* recommended). You can use the Azure AI Foundry portal to deploy the models into your Azure OpenAI service. The two models are assumed to be deployed with the following names:

- Chat model: `gpt-4o`
- Embedding model: `text-embedding-ada-002`

## Deploy Sample Database

> [!NOTE]  
> Vector Functions are in Public Preview. Learn the details about vectors in Azure SQL here: <https://aka.ms/azure-sql-vector-public-preview>

To deploy the database, you can either use the provided .NET 8 Core console application or do it manually.

> **IMPORTANT**: Wait at least 5 minutes after completing your Azure resource deployment to run the database scripts. This provides time for your embedding model in Azure OpenAI to be available from Azure SQL for generating embeddings.

### Use Provided .NET 8 Core Console App

To use the .NET 8 Core console application:

1. Change directories into the `/database` in to solution.
2. Create a `.env` file in the `/database` folder, using the `.env.example` file as a starter, and populute the following environment variables with values from your environment:

   - `MSSQL`: The connection string to the Azure SQL database where you want to deploy the database objects and sample data.

     - If you used the Azure Developer CLI template, select the `ADO.NET` (Microsoft Entra passwordless authentication) connection string from your database's connection strings page. Otherwise, select the connection string appropriate for the authentication method you set up on your database.

   - `OPENAI_URL`: Provide the URL of your Azure OpenAI endpoint, e.g., '<https://my-open-ai.openai.azure.com/>'.

     > **IMPORTANT**: Ensure the URL ends with "/".

   - `OPENAI_KEY`: Specify the API key of your Azure OpenAI endpoint.
   - `OPENAI_MODEL`: Provide the deployment name of your Azure OpenAI embedding endpoint (e.g., 'text-embedding-ada-002').

To run the .NET 8 Core console application:

1. Open a new terminal windows in VS Code.

2. Sign into Azure using the Azure CLI:

    ```bash
    az login
    ```

3. At the terminal prompt, change directories to the `/database` folder:

    ```bash
    cd database
    ```

4. Build the database project:

    ```bash
    dotnet build
    ```

5. Run the database project:

    ```bash
    dotnet run
    ```

### Manual Database Deployment

If you prefer to deploy the database manually, you must run each of the scripts in the `/database/sql` folder of the solution against your database. Ensure you execute the scripts in the `/database/sql` folder in the order specifed by the number in the file name. Some files (`020-security.sql` and `060-get_embedding.sql`) have placeholders that you must replace with your own values:

- `$OPENAI_URL$`: replace with the URL of your Azure OpenAI endpoint, eg: '<https://my-open-ai.openai.azure.com/>'
- `$OPENAI_KEY$`: replace with the API key of your Azure OpenAI endpoint
- `$OPENAI_MODEL$`: replace with the deployment name of your Azure OpenAI embedding model, eg: 'text-embedding-ada-002'

## Verify Embeddings In Database

To run the solution, vector embeddings must be inserted into the `[web].[sessions]` and `[web].[speakers]` tables in the database. This should be accomplished by the database deployment scripts you executed in the previous step. In this task, you connect to your database to ensure the embeddings were properly inserted.

1. Connect to your database using your preferred database management tool, such as the Query Editor in the Azure Portal, VS Code and the MSSQL extension, SSMS, or Azure Data Studio.

2. Select the top 5 rows from the `[web].[sessions]` table and verify the `embeddings` column contains vector arrays for each row.

3. Repeat the above step against the `[web].[speakers]` table.

If your tables do not contain embeddings, you will need to manually rerun the `040-tables.sql` and `100-sample-data.sql` scripts in the `/database/sql` folder of the solution against your database. This will drop and create the tables, and then attempt to repopulate them with sample data. If there is an error generating embeddings, you will see it when executing the `100-sample-data.sql` script. Typical errors include not waiting long enough after deploying your embedding model to Azure OpenAI before running the script and not having an embedding model deployment with the name `text-embedding-ada-002` in your Azure OpenAI service.

## Chainlit App

The Chainlit solution is located in `chainlit` folder. To get started with the application:

1. In VS Code, open a new integrated terminal window and change directories to the `/chainlit` folder.

2. Create a Python virtual environment:

    ```bash
    python -m venv .venv
    ```

3. Activate the virtual environment

    On Windows:

    ```powershell
    .venv\Script\activate
    ```

    On Linux or Mac:

    ```bash
    source .venv/bin/activate
    ```

4. Install the required Python libraries:

    ```bash
    pip install -r requirements.txt
    ```

5. Create a `.env` file in the `/chainlit` folder starting from the `.env.example` file and populate it with the values for your environment.

    The `AZURE_SQL_CONNECTION_STRING` variable should look like the following, with the `[YOUR_SQL_SERVER_NAME]` token replaced with the name of your SQL server in Azure. If you named your database differently, you will also need to update the `Database` value.

    ```ini
    AZURE_SQL_CONNECTION_STRING='Driver={ODBC Driver 18 for SQL Server};Server=tcp:[YOUR_SQL_SERVER_NAME].database.windows.net,1433;Database=sessiondb;Encrypt=yes;Connection Timeout=30;'
    ```

6. Install the ODBC Driver for SQL Server:

    On codespaces:

    ```bash
    sudo su
    ```

    ```bash
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    ```

    ```bash
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
    ```

    ```bash
    exit
    ```

    ```bash
    sudo apt-get update
    ```

    ```bash
    sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc unixodbc-dev
    ```

    On Windows:

    [Download the ODBC driver for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver16)

7. Then, run the chainlit solution:

    ```bash
    chainlit run app.py
    ```

    Or, if you want to use the LangGraph solution:

    ```bash
    chainlit run app-langgraph.py
    ```

8. Once the application is running, you'll be able to ask question about your data and get the answer from the Azure OpenAI model. For example you can ask question on the data you have in the database:

    ```text
    Are there any sessions on Retrieval Augmented Generation?
    ```

You'll see that Langchain will call the function `get_similar_sessions` that behind the scenes connects to the database and excute the stored procedure `web.find_sessions` which perform vector search on database data.

The RAG process is defined using Langchain's LCEL [Langchain Expression Language](https://python.langchain.com/v0.1/docs/expression_language/) that can be easily extended to include more complex logic, even including complex agent actions with the aid of [LangGraph](https://langchain-ai.github.io/langgraph/), where the function calling the stored procedure will be a [tool](https://langchain-ai.github.io/langgraph/how-tos/tool-calling/?h=tool) available to the agent.

### Azure Functions (optional)

In order to automate the process of generating the embeddings, you can use the Azure Functions. Thanks to [Azure SQL Trigger Binding](https://learn.microsoft.com/azure/azure-functions/functions-bindings-azure-sql-trigger), it is possible to have tables monitored for changes and then react to those changes by executing some code in the Azure Function itself. As a result, it is possible to automate the process of generating the embeddings and storing them in the database.

In a perfect microservices architecture, the Azure Functions are written in C#, but you can easily create the same solution using Python, Node.js or any other supported language.

The Azure Functions solution is in the `azure-functions` folder. Move into the folder, then create a `local.settings.json` starting from the provided `local.settings.json.example` file and fill it with your own values. Then run the Azure Functions locally (make sure to have the [Azure Function core tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) installed):

```bash
func start
```

The Azure Function will monitor the configured tables for changes and automatically call the Azure OpenAI endpoint to generate the embeddings for the new or updated data.

To trigger the function:

1. In your database management tool, run the following query:

    ```sql
    UPDATE [web].[speakers] SET [require_embeddings_update] = 1;
    ```

2. Observe the function output in the VS Code terminal window. You should see update changes being processed against the `web.speakers` table.

## Cleanup

Once you have completed this workshop, delete the Azure resources you created. You are charged for the configured capacity, not how much the resources are used. Follow these instructions to delete your resource group and all resources you created for this solution accelerator.

### Persist changes to GitHub

If you want to save any changes you have made to files, use the Source Control tool in VS Code to commit and push your changes to your fork of the GitHub repo.

### Azure Developer CLI Deployed Resources

1. In VS Code, open a new integrated terminal prompt.

2. At the terminal prompt, execute the following command to delete the resources created by the deployment script:

    ```bash
    azd down --purge
    ```

    The `--purge` flag purges the resources that provide soft-delete functionality in Azure, including Azure KeyVault and Azure OpenAI. This flag is required to remove all resources completely.

3. In the terminal window, you will be shown a list of the resources that will be deleted and prompted about continuing. Enter "y" at the prompt to being the resource deletion.

### Manually Provisioned Resources

1. In the Azure portal, select the resource group to which you deployed resources.

2. Delete the resource group.
