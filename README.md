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

The solution requires an Azure SQL database and Azure OpenAI service for vector embedding and chat completions, but it can be run locally or in Azure. Running the complete solution in Azure would require the Chainlit application to be containerized and deployed to Azure using one of the available options for hosting containerized applications, such as Azure Container Apps or Azure Kubernetes Service (AKS). However, that is not covered in this sample.

## Quick Start

The fastest way to try out the sample application is to use GitHub Codespaces and to deploy the required Azure resources by running the [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview?tabs=windows) template and bicep scripts included in the repo.

The template will deploy a small Azure SQL database and an Azure OpenAI service with the required `gpt-4o` and `text-embedding-ada-002` models. It can also be used to optionally deploy an Azure Function App.

> **NOTE**: It is also possible to leverage an existing Azure SQL database and Azure OpenAI service in your subscription to run the solution. Using that approach, you must deploy the database and ensure the correct Azure OpenAI models are deployed.

### Create Codespace

GitHub Codespaces allow you to start developing in a secure, configurable, and dedicated environment based on a development container specification. Development containers, or dev containers, are Docker containers that are specifically configured to provide a fully featured development environment. Whenever you work in a codespace, you are using a dev container on a virtual machine.

You can view the dev container specification for this project in the `.devcontainer/devcontainer.json` file.

1. Navigate to the [Azure SQL DB LangChain RAG with Chainlit repo](https://aka.ms/azuresqldb-rag-langchain-chainlit).

2. Fork the repo.

3. On your fork, create a codespace by selecting **Code --> Codespaces --> Create codespace...**.

4. It will take about 10 minutes for the codespace to be created and set up.

    > Codespaces is configured to use a Python 11 image

### Provision Azure Resources

Azure Developer CLI templates are run using the `azd up` command from an integrated terminal window in VS Code. Follow the steps below to execute the template and provision the necessary Azure resources:

1. Open a new terminal windows in VS Code.

2. Sign into the Azure Developer CLI:

    ```bash
    azd auth login
    ```

3. Run the deployment command to execute

    ```bash
    azd up
    ```

4. At the terminal prompt
    Enter an environment name, such as "dev" or "test."
    Select the subscription you want to use for the resources for this solution.
    Select `True` if you would like to deploy the Azure Function App resource. Otherwise, select `False`.
    Select the Azure region into which you would like to deploy the resources for this solution. TODO: Add note about [region selection for Azure OpenAI models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=standard%2Cstandard-chat-completions#models-by-deployment-type), as well as requirement for 10,000 TPMs of capacity in the region for each model.
    Enter a resource group name, such as `rg-azure-sql-rag-app`.
    Enter a strong password for the Azure SQL Admin account. Note, this is needed to deploy the database, but the Bicep script will configure the SQL Server and database to use Microsoft Entra ID authentication only.

NOTE: The Azure Function app is an optional component, so you will be prompted during the deployment to specify if you would like to provision a function app in Azure.






### Azure Open AI

Before getting started, make sure to have two models deployed, one for generating embeddings (*text-embedding-ada-002* model recommended) and one for handling the chat (*gpt-4o* recommended). You can use the Azure OpenAI service to deploy the models. Make sure to have the endpoint and the API key ready. The two models are assumed to be deployed with the following names:

- Embedding model: `text-embedding-ada-002`
- Chat model: `gpt-4o`

TODO: Add links to pages where regions supporting the above models can be identified.

TODO: Add short section on using Azure AI Foundry to create/verify model deployments.

### Database

> [!NOTE]  
> Vector Functions are in Public Preview. Learn the details about vectors in Azure SQL here: <https://aka.ms/azure-sql-vector-public-preview>

To deploy the database, you can either use the provided .NET 8 Core console application or do it manually.

To use the .NET 8 Core console application, change directories into the `/database` and then make sure to create a `.env` file in the `/database` folder starting from the `.env.example` file:

- `MSSQL`: the connection string to the Azure SQL database where you want to deploy the database objects and sample data
- `OPENAI_URL`: specify the URL of your Azure OpenAI endpoint, eg: '<https://my-open-ai.openai.azure.com/>'
- `OPENAI_KEY`: specify the API key of your Azure OpenAI endpoint
- `OPENAI_MODEL`: specify the deployment name of your Azure OpenAI embedding endpoint, eg: 'text-embedding-3-small'

To run the .NET 8 Core console application:

1. Open a new terminal windows in VS Code.

2. Sign into Azure by ent the Azure CLI:

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

If you prefer to deploy the database manually, make sure to execute the scripts in the `/database/sql` folder in the order specifed by the number in the file name. Some files (`020-security.sql` and `060-get_embedding.sql`) have placeholders that you must replace with your own values:

- `$OPENAI_URL$`: replace with the URL of your Azure OpenAI endpoint, eg: '<https://my-open-ai.openai.azure.com/>'
- `$OPENAI_KEY$`: replace with the API key of your Azure OpenAI endpoint
- `$OPENAI_MODEL$`: replace with the deployment name of your Azure OpenAI embedding model, eg: 'text-embedding-ada-002'

#### Connect to the database

TODO: Add section here about connecting to the database using the MSSQL extension for VS Code. (Provide link in guide to here as well.)

### Chainlit

TODO: Update instructions for anyone using codespaces, as the venv will have already been created and the requirements.txt file will have been installed in the venv. (will still need to activate the .venv before running chainlit command...)

Chainlit solution is in `chainlit` folder. Move into the folder, create a virtual environment and install the requirements:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

or, on Windows:

```powershell
python -m venv .venv
.venv\Script\activate
pip install -r requirements.txt
```

Then ensure you create an `.env` file in the `/chainlit` folder starting from the `.env.example` file and it with the values for your environment.

TODO: Need to talk about how to put together the correct connection string when not using SQL auth. Using Entra ID, they will not need the `Uid` or `Password` parameters...

```ini
AZURE_SQL_CONNECTION_STRING='Driver={ODBC Driver 18 for SQL Server};Server=tcp:[YOUR_SQL_SERVER_NAME].database.windows.net,1433;Database=[YOUR_DATABASE_NAME];Encrypt=yes;Connection Timeout=30;'
```

Then, run the chainlit solution:

```bash
chainlit run app.py
```

or

```bash
chainlit run app-langgraph.py
```

if you want to use the LangGraph solution.

Once the application is running, you'll be able to ask question about your data and get the answer from the Azure OpenAI model. For example you can ask question on the data you have in the database:

```text
Is there any session on Retrieval Augmented Generation?
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

TODO: Add short section on adding new records to the database and what flag needs to be set to true for the function app to pick it up and generate embeddings.
