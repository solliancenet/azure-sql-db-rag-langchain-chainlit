# Azure SQL DB, Langchain, LangGraph and Chainlit

This repository showcases a simple AI-powered chat application built using Python and leveraging the power of [Chainlit](https://docs.chainlit.io/get-started/overview) and [LangChain](https://www.langchain.com/) to implement retrieval-augmented generation (RAG). The project, which stems from the innovative demonstrations presented at the [#RAGHack](https://github.com/microsoft/RAG_Hack) event, allows users to submit natural language queries about event sessions and speakers using [vector similarity search with Azure SQL and Azure OpenAI](https://learn.microsoft.com/en-us/samples/azure-samples/azure-sql-db-openai/azure-sql-db-openai/). For additional insights and to access the recording, visit the discussion: [RAG on Azure SQL Server](https://github.com/microsoft/RAG_Hack/discussions/53).

The application provides two implementations of the RAG process:

1. A straightforward version using LangChain (`app.py`)
2. A dynamic approach using LangGraph (`app-langgraph.py`)

The app demonstrates how Azure SQL Database and the RAG pattern can enhance data retrieval and utilization in a copilot chat application.

## Architecture

![Application architecture](./_assets/architecture.png)

The Chainlit application implements the RAG pattern, utilizing LangChain and function calling to perform vector similarity searches over data stored in an Azure SQL database. Within the database, a stored procedure is used to call an Azure OpenAI endpoint to generate vector embeddings representing the search query using an embedding model. These embeddings are then compared against previously stored vectors using Azure SQL's built-in [VECTOR_DISTANCE function](https://learn.microsoft.com/sql/t-sql/functions/vector-distance-transact-sql?view=azuresqldb-current) to identify sessions and speakers that are semantically similar to the query. Vector representations of speaker names and session titles and abstracts are stored in the database using Azure SQL Database's native [Vector data type](https://learn.microsoft.com/sql/t-sql/data-types/vector-data-type?view=azuresqldb-current&tabs=csharp-sample).

> [!NOTE]  
> Vector Functions are in Public Preview. Learn the details about vectors in Azure SQL here: <https://aka.ms/azure-sql-vector-public-preview>

Embeddings stored in the database can be kept up-to-date using an Azure Function App and [Azure SQL Trigger Binding](https://learn.microsoft.com/azure/azure-functions/functions-bindings-azure-sql-trigger). Whenever changes occur in designated tables in the database, the function is triggered, directly calling Azure OpenAI to generate embeddings for new or updated records. The vectors are then written into the database.

The application is composed of three main Azure components:

- [Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/sql-database-paas-overview?view=azuresql): The Azure SQL database that stores application data.
- [Azure Open AI](https://learn.microsoft.com/azure/ai-services/openai/): Hosts the language models for generating embeddings and completions.
- [Azure Functions](https://learn.microsoft.com/azure/azure-functions/functions-overview?pivots=programming-language-csharp): The serverless function to automate the process of generating the embeddings (this is optional for this sample)

The solution can be run locally or in Azure. However, running the complete solution in Azure requires the Chainlit application to be containerized and deployed to Azure using one of the available options for hosting containerized applications, such as Azure Container Apps or Azure Kubernetes Service (AKS). The steps for that are not covered in the instructions for this solution.

## Try It Out

The fastest way to try out the sample application is to follow the instructions below for creating a GitHub Codespace and deploying the required Azure resources by running the [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview?tabs=windows) template and Bicep scripts included in the repo.

You can also deploy resources manually or use existing ones in your Azure subscription.

## Set Up Your Development Environment

The recommended approach to setting up a development environment for this solution is utilizing **GitHub Codespaces**, which offers a streamlined, ready-to-use workspace requiring minimal configuration. If you can't access codespaces or would rather work locally, this section includes instructions to help you configure **VS Code** locally for a smooth development experience.

### Create a Codespace

GitHub Codespaces provides a secure, customizable workspace built on a development container specification, enabling a seamless coding experience. These development containers, called dev containers, are Docker-based environments tailored for software development. When working within a codespace, your code runs inside a dev container hosted on a virtual machine, ensuring consistency and efficiency in your workflow.

This solution includes a preconfigured dev container that you can use to set up a codespace on GitHub. You can view the dev container specification for this project in the repo file `.devcontainer/devcontainer.json`.

To set up a codespace:

1. Navigate to the [Azure SQL DB LangChain RAG with Chainlit repo](https://aka.ms/azuresqldb-rag-langchain-chainlit).
2. Fork the repo.
3. On your fork, create a codespace by selecting **Code --> Codespaces --> Create codespace...**.
4. The codespace will take about 10 minutes to be created and fully configured.

Once your codespace has been created, you will **complete the remaining tasks from the VS Code instance within your codespace** environment. You can skip to the [Provision Azure Resources](#provision-azure-resources) section below.

### Use Your Local Machine

If you cannot access GitHub Codespaces or prefer to use your local machine, follow the instructions below to configure a development environment on your local machine using Visual Studio Code and Python.

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

4. [Microsoft ODBC Driver for SQL Server](https://learn.microsoft.com/sql/connect/odbc/microsoft-odbc-driver-for-sql-server?view=sql-server-ver16)

After installing the above tools, clone the [Azure SQL DB LangChain RAG with Chainlit repo](https://aka.ms/azuresqldb-rag-langchain-chainlit) and open it in VS Code.

## Provision Azure Resources

The solution requires an Azure SQL database and an Azure OpenAI service. You can optionally deploy an Azure Function App to automate the generation of vector embeddings for new and updated data.

Using the provided Azure Developer CLI template to deploy the required resources into your Azure subscription is the easiest way to get started with this solution. However, you can also opt to manually deploy the resources or use existing services in your subscription.

### Using Azure Developer CLI Template

The template provided in this repo will deploy a small Azure SQL database and an Azure OpenAI service with the required `gpt-4o` and `text-embedding-ada-002` models. It can also be used to deploy an Azure Function App.

Azure Developer CLI templates are run using the `azd up` command. Follow the steps below to provision the necessary Azure resources using the template:

1. Open a new terminal windows in VS Code.

2. Sign into Azure using the Azure CLI:

    ```bash
    az login
    ```

3. Sign in to the Azure Developer CLI:

    ```bash
    azd auth login
    ```

4. Run the deployment command to execute the included Bicep scripts:

    ```bash
    azd up
    ```

5. After issuing the `azd up` command, you will be prompted for several values. Provide the requested information to provision and deploy the Azure resources:

    - Enter an environment name, such as "dev" or "test."
    - Select the subscription you want to use for the resources for this solution.
    - Indicate if you want to deploy an Azure Function App.

      > Deploying an Azure Function app is an optional component of the solution. You can run and test the function in your codespace or locally if you prefer not to deploy the function to Azure.

    - Select the Azure region where you would like to deploy the resources for this solution.

      > [!NOTE]
      > The Bicep script will deploy an Azure OpenAI service and create deployments for the `gpt-4o` and `text-embedding-ada-002` models. To ensure the deployment succeeds, review the [regional availability for Azure OpenAI models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models?tabs=standard%2Cstandard-chat-completions#models-by-deployment-type) before selecting a region. You should also verify you have at least 10,000 TPMs of available capacity for each model.

    - Enter a resource group name, such as `rg-azure-sql-rag-app`.
    - Enter a strong password for the Azure SQL Admin account. Note that this is needed to deploy the database, but the Bicep script will configure the SQL Server and database to use Microsoft Entra ID authentication only.

6. Skip to [Deploy Sample Database](#deploy-sample-database) below.

### Manually Provision Resources

You can manually deploy the required Azure resources using the Azure CLI or Azure portal. You must create an Azure SQL database and Azure OpenAI service. Optionally, you can provision an Azure Function App to host the sample function.

For the database, ensure you add the IP address of your local machine to the SQL Server's firewall.

To run the solution, you must deploy two models to your Azure Open AI service:

1. A text embedding model for generating embeddings (*text-embedding-ada-002* model recommended)
2. A chat model for handling the chat (*gpt-4o* recommended)

You can use the Azure AI Foundry portal to deploy the required models into your Azure OpenAI service. The two models are assumed to be deployed with the following names:

- Chat model: `gpt-4o`
- Embedding model: `text-embedding-ada-002`

Once your resources are deployed, skip to [Deploy Sample Database](#deploy-sample-database) below.

### Use Existing Azure Resources

Leveraging an existing Azure SQL database and Azure OpenAI service in your subscription to run the solution is also possible. Using that approach, you must deploy the sample database onto your Azure SQL server and ensure the correct models are deployed into your Azure OpenAI service.

Ensure your Azure Open AI service has two models deployed, one for generating embeddings (*text-embedding-ada-002* model recommended) and one for handling the chat (*gpt-4o* recommended). You can use the Azure AI Foundry portal to deploy the models into your Azure OpenAI service. The two models are assumed to be deployed with the following names:

- Chat model: `gpt-4o`
- Embedding model: `text-embedding-ada-002`

## Deploy Sample Database

To deploy the database, you can either use the provided .NET 8 Core console application or do it manually by running the scripts in the solution's `/database/sql` folder.

> [!NOTE]
> You should wait at least 5 minutes after completing your Azure resource deployment to run the database scripts to ensure the deployed embedding model endpoint in Azure OpenAI is available and ready to generate embeddings.

### Use Provided .NET 8 Core Console App

To use the .NET 8 Core console application to deploy the database:

1. Navigate to the `/database` folder in the repo.
2. Create a `.env` file in the `/database` folder, using the `.env.example` file as a starter, and populate the following environment variables with values from your environment:

   - `MSSQL`: The connection string to the Azure SQL database where you want to deploy the database objects and sample data.

     - If you used the Azure Developer CLI template, select the `ADO.NET` (Microsoft Entra passwordless authentication) connection string from your database's connection strings page. Otherwise, select the connection string appropriate for the authentication method you set up on your database.

   - `OPENAI_URL`: Provide the URL of your Azure OpenAI endpoint, e.g., '<https://my-open-ai.openai.azure.com/>'. **Ensure the URL ends with "/"**.

   - `OPENAI_KEY`: Specify the API key of your Azure OpenAI endpoint.
   - `OPENAI_MODEL`: Provide the deployment name of your Azure OpenAI embedding endpoint (e.g., 'text-embedding-ada-002').

To run the .NET 8 Core console application:

1. Open a new integrated terminal in VS Code.

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

If you prefer to deploy the database manually, you must run each of the scripts in the solution's `/database/sql` folder against your database. Ensure you execute the scripts in the `/database/sql` folder in the order specified by the number in the file name. Some files (`020-security.sql` and `060-get_embedding.sql`) have placeholders that you must replace with your values:

- `$OPENAI_URL$`: replace with the URL of your Azure OpenAI endpoint, e.g., '<https://my-open-ai.openai.azure.com/>'
- `$OPENAI_KEY$`: replace with the API key of your Azure OpenAI endpoint
- `$OPENAI_MODEL$`: replace with the deployment name of your Azure OpenAI embedding model, e.g., 'text-embedding-ada-002'

## Verify Embeddings In Database

Vector embeddings must be inserted into the `[web].[sessions]` and `[web].[speakers]` tables in the database prior to running the Chainlit application. The database deployment scripts executed in the previous step should have accomplished this, but the embeddings should be verified before proceeding.

1. Connect to your database using your preferred database management tool, such as VS Code and the MSSQL extension, SSMS, Query Editor in the Azure Portal, or Azure Data Studio.

2. Select the top 5 rows from the `[web].[sessions]` table and verify the `embeddings` column contains vector arrays for each row.

3. Repeat the above step against the `[web].[speakers]` table.

If your tables do not contain embeddings, you must manually rerun the `040-tables.sql` and `100-sample-data.sql` scripts in the solution's `/database/sql` folder against your database. These scripts will drop and recreate the tables and then attempt to repopulate them with sample data and embeddings. If there is an error generating embeddings, you will see it when executing the `100-sample-data.sql` script. Typical errors include not waiting long enough after deploying your embedding model to Azure OpenAI before running the script and not having an embedding model deployment with the expected name of `text-embedding-ada-002` in your Azure OpenAI service.

## Run the Chainlit App

The Chainlit application provides a simple Python-based chat interface for interacting with data in your database. The Chainlit solution is located in the `chainlit` folder. To get started with the application:

1. Open a new integrated terminal in VS Code.

2. Sign into Azure using the Azure CLI:

    ```bash
    az login
    ```

3. Change directories to the `/chainlit` folder.

    ```bash
    cd chainlit
    ```

4. Create a Python virtual environment named `.venv`:

    ```bash
    python -m venv .venv
    ```

5. Activate the virtual environment:

    On Windows:

    ```powershell
    .venv\Script\activate
    ```

    On Linux or Mac:

    ```bash
    source .venv/bin/activate
    ```

6. Install the required Python libraries from the `requirements.txt` file:

    ```bash
    pip install -r requirements.txt
    ```

7. In the VS Code Solution Explorer, navigate to the `/chainlit` folder, create a `.env` file, starting from the `.env.example` file, and populate it with the values for your environment.

    Microsoft Entra ID Auth is required if you used the Azure Developer CLI template to deploy your database. Therefore, your `AZURE_SQL_CONNECTION_STRING` variable should look like the following, with the `[YOUR_SQL_SERVER_NAME]` token replaced with the name of your SQL server in Azure. If you named your database differently, you must also update the `Database` value.

    ```ini
    AZURE_SQL_CONNECTION_STRING='Driver={ODBC Driver 18 for SQL Server};Server=tcp:[YOUR_SQL_SERVER_NAME].database.windows.net,1433;Database=sessiondb;Encrypt=yes;Connection Timeout=30;'
    ```

8. If you are using codespaces, you must install the ODBC Driver for SQL Server on the container:

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

9. Then, run the chainlit solution:

    ```bash
    chainlit run app.py
    ```

    Or, if you want to use the LangGraph solution:

    ```bash
    chainlit run app-langgraph.py
    ```

10. Once the application is running, you can ask questions about your data and get the answer from the Azure OpenAI model. For example, you can ask questions about the session topics you have in the database:

    - Are there any sessions on retrieval-augmented generation?
    - Show me sessions featuring Azure SQL.

You'll see that Langchain will call the function `get_similar_sessions` that, behind the scenes, connects to the database and executes the stored procedure `web.find_sessions`, which performs vector search on database data.

The RAG process is defined using Langchain's LCEL [Langchain Expression Language](https://python.langchain.com/v0.1/docs/expression_language/) that can be easily extended to include more complex logic, even including complex agent actions with the aid of [LangGraph](https://langchain-ai.github.io/langgraph/), where the function calling the stored procedure will be a [tool](https://langchain-ai.github.io/langgraph/how-tos/tool-calling/?h=tool) available to the agent.

## Run the Azure Function App (optional)

To automate the process of generating the embeddings for new and updated session and speaker data, you can use Azure Functions. Thanks to [Azure SQL Trigger Binding](https://learn.microsoft.com/azure/azure-functions/functions-bindings-azure-sql-trigger), it is possible to have tables monitored for changes and then react to those changes by executing code in the Azure Function itself. As a result, it is possible to automate the process of generating the embeddings and storing them in the database.

In this solution, the Azure Function is written in C#, but you can easily create the same solution using Python, Node.js or any other supported language. The Azure Functions solution is in the `azure-functions` folder.

1. Navigate to the `azure-functions` folder in the solution, then create a `local.settings.json` starting from the provided `local.settings.json.example` file, and populate it with your values.

2. Run the Azure Function locally (ensure you have the [Azure Function core tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) installed):

    ```bash
    func start
    ```

    The Azure Function will monitor the configured tables for changes and automatically call the Azure OpenAI endpoint to generate the embeddings for the new or updated data.

3. To trigger the function, run the following query against your database to update the `require_embeddings_update` flag in the `web.speakers` table:

    ```sql
    UPDATE [web].[speakers] SET [require_embeddings_update] = 1;
    ```

4. Observe the function output in the VS Code integrated terminal window. You should see update changes being processed against the `web.speakers` table.

You can also choose to deploy the function to your Function App instance in Azure if you opted to deploy that service.

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

## Code walkthoughh

Refer to the [code walkthrough document](walkthrough.md) for a details explanation of the code structure and how the different compontents work together.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
