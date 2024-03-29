# OpenSearch 
Bedework uses OpenSearch as the indexer engine. As objects are created destroyed and updated they are indexed through calls to the indexer. The indexer can run as an embedded engine - as it arrives in the quickstart - or as an external service - which will be required for clustering.

Currently OpenSearch is completely unsecured. For testing and debugging it is possible to enable the http interface but this may expose your index. DO NOT run in production with the ES http interface open. In embedded mode the only access should be through the api.

Later versions of ES do appear to offer the ability to secure ES. This may be an option when we upgrade.

In non-embedded mode you can run ES on the same server or preferably a different server. ES - depending on the amount of data and types of search - can use a lot of memory for caching of filters. See the ES site for full instructions on running a non-embedded version.

In general this is an easy process - ES offers various installation formats of all their versions including the very old 15.2 we are running currently.

Both embedded and non-embedded require a small number of changes to the configuration. These are already in place for the embedded version and are available in the quickstart in

bedework/config/bedework/elasticsearch/config/elasticsearch.yml

Note that the mappings and settings do not need to be installed. They are used when creating a new index.

The changes made are

**action.auto_create_index: false**

Prevent ES from creating indexes implicitly. This can cause issues when reindexing.

Uncomment the following

**node.max_local_storage_nodes: 1**
