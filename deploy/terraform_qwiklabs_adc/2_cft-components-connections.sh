SPACE_ID="default-space"
CATALOG_ID="default-catalog"
export PROJECT_ID=$1

echo "Setting up environment for Project: ${PROJECT_ID}"
gcloud config set project $PROJECT_ID


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-sql-db",
    "dir": "modules/postgresql",
    "refTag": "v26.2.2"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "iam_users",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"id\": service_account_id.id, \"email\": service_account_id.email, \"type\": \"CLOUD_IAM_SERVICE_ACCOUNT\"}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"id\": id, \"email\": email, \"type\": \"CLOUD_IAM_SERVICE_ACCOUNT\"}"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/postgresql/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-service-accounts",
    "dir": "modules/simple-sa",
    "refTag": "v4.6.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/storage.objectAdmin\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/secretmanager.secretAccessor\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/bigquery.dataEditor\", \"roles/bigquery.jobUser\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/cloudsql.client\"]"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/service-account/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-lb-http",
    "dir": "modules/backend",
    "refTag": "v13.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "serverless_neg_backends",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"service_name\": service_name, \"region\": location, \"type\": \"cloud-run\"}"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/global-lb-backend/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-vertex-ai",
    "dir": "modules/model-armor-template",
    "refTag": "v2.3.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": []
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vertex-model-armor-template/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-vertex-ai",
    "dir": "modules/model-armor-floorsetting",
    "refTag": "v2.3.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "parent_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "project"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vertex-model-armor-floorsetting/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-cloud-run",
    "dir": "modules/v2",
    "refTag": "v0.21.6"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "containers",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_SQL_DATABASE_HOST\" : instance_first_ip_address, \"CLOUD_SQL_DATABASE_CONNECTION_NAME\" : instance_connection_name, \"CLOUD_SQL_DATABASE_NAME\" : env_vars.CLOUD_SQL_DATABASE_NAME}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"APPLICATION_SECRET\": {\"secret\": id, \"version\": version}}",
                  "inputPath": "env_secret_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"GCS_BUCKET_NAME\": name}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"BIGQUERY_PROJECT\": project_id, \"BIGQUERY_DATASET\": dataset_id, \"BIGQUERY_LOCATION\": location}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"SERVICE_ENDPOINT\": service_uri}",
                  "inputPath": "env_vars"
                }
              }
            ]
          },
          {
            "name": "service_account_project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/secretmanager.secretAccessor\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/storage.objectAdmin\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/bigquery.dataUser\", \"roles/bigquery.jobUser\"]"
                }
              }
            ]
          },
          {
            "name": "service_account",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "email"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-run/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-tags",
    "refTag": "v0.3.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": []
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/tags/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/cloud-foundation-fabric",
    "dir": "modules/agent-engine",
    "refTag": "v51.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "agent_engine_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_RUN_SERVICE_URI\": service_uri}",
                  "inputPath": "environment_variables"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"AGENT_SECRET\": {\"secret_id\": id, \"version\": version}}",
                  "inputPath": "secret_environment_variables"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"PG_HOST\": instance_first_ip_address, \"PG_HOST_DNS\": dns_name, \"PG_DATABASE\": env_vars.CLOUD_SQL_DATABASE_NAME}",
                  "inputPath": "environment_variables"
                }
              }
            ]
          },
          {
            "name": "service_account_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"email\": email, \"create\": false}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/secretmanager.secretAccessor\"]",
                  "inputPath": "roles"
                }
              }
            ]
          },
          {
            "name": "bucket_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"name\": name}"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/agent-engine/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-lb-http",
    "dir": "modules/frontend",
    "refTag": "v13.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "url_map_input",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-lb-http//modules/backend",
                  "version": ">=13.2.0"
                },
                "spec": {
                  "outputExpr": "backend_service_info"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[{\"host\": \"*\", \"path\": \"/*\", \"backend_service\": service_name}]"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/global-lb-frontend/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-cloud-storage",
    "dir": "modules/simple_bucket",
    "refTag": "v12.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": []
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gcs-storage/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-bigquery",
    "refTag": "v10.2.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "external_tables",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"source_uris\": [url], \"source_format\": \"CSV\", \"autodetect\": true}"
                }
              }
            ]
          },
          {
            "name": "access",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "[{\"role\": \"roles/bigquery.dataOwner\", \"userByEmail\": email}]"
                }
              }
            ]
          }
        ]
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/bigquery/revisions?catalog_template_revision_id=r-1"




curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-secret-manager",
    "dir": "modules/simple-secret",
    "refTag": "v0.9.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": []
      }
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/secret-manager/revisions?catalog_template_revision_id=r-1"


