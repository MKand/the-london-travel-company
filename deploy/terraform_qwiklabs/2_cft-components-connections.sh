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
    "repo": "GoogleCloudPlatform/terraform-google-out-of-band-security",
    "refTag": "v0.19.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "mgmt_network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "mgmt_subnet",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_names[0]"
                }
              }
            ]
          },
          {
            "name": "scopes",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"https://www.googleapis.com/auth/bigquery\"]"
                }
              }
            ]
          },
          {
            "name": "compute_instance_metadata",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"SECRET_MANAGER_ID\": id}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/out-of-band-security/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpc-service-controls",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "restricted_services",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"redis.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"bigquery.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-spanner",
                  "version": ">=1.2.1"
                },
                "spec": {
                  "outputExpr": "[\"spanner.googleapis.com\"]"
                }
              }
            ]
          },
          {
            "name": "projects",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[project]"
                }
              }
            ]
          },
          {
            "name": "scopes",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-autopilot-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "version": ">=0.0.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-folders",
                  "version": ">=5.1.0"
                },
                "spec": {
                  "outputExpr": "[name]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/${project_id}\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-project-factory",
                  "version": ">=18.2.0"
                },
                "spec": {
                  "outputExpr": "\"projects/\" + project_number"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-data-fusion",
                  "version": ">=4.1.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/${tenant_project}\"]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpc-service-controls/revisions?catalog_template_revision_id=r-1"


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
          },
          {
            "name": "ip_configuration",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\"private_network\": network_self_link}"
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
    "repo": "terraform-google-modules/terraform-google-kubernetes-engine",
    "dir": "modules/gke-node-pool",
    "refTag": "v41.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "cluster",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "name"
                }
              }
            ]
          },
          {
            "name": "network_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\"network\": network_self_link, \"subnetwork\": subnets_self_links[0]}",
                  "inputPath": "additional_node_network_configs"
                }
              }
            ]
          },
          {
            "name": "node_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "email",
                  "inputPath": "service_account"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"POSTGRES_DB_HOST\": instance_first_ip_address, \"POSTGRES_DB_NAME\": env_vars.CLOUD_SQL_DATABASE_NAME, \"POSTGRES_INSTANCE_CONNECTION_NAME\": instance_connection_name}",
                  "inputPath": "metadata"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gke-node-pool/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vm",
    "dir": "modules/mig",
    "refTag": "v13.6.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "instance_template",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/instance_template",
                  "version": ">=13.5.0"
                },
                "spec": {
                  "outputExpr": "self_link"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gce-mig/revisions?catalog_template_revision_id=r-1"


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
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/compute.instanceAdmin.v1\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-project-factory//modules/project_services",
                  "version": ">=18.0.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/aiplatform.user\"]"
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
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/pubsub.editor\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-event-function",
                  "version": ">=6.0.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/run.invoker\", \"roles/eventarc.eventReceiver\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/logging.logWriter\", \"roles/monitoring.viewer\", \"roles/monitoring.metricWriter\", \"roles/storage.objectViewer\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-composer",
                  "version": ">=6.3.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/composer.worker\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-deploy",
                  "version": ">=0.3.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/clouddeploy.jobRunner\", \"roles/iam.serviceAccountUser\"]"
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
    "repo": "terraform-google-modules/terraform-google-datalab",
    "dir": "/",
    "refTag": "v2.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "env_vars",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"MYSQL_HOST\": instance_first_ip_address, \"MYSQL_DATABASE\": env_vars.DB_NAME, \"MYSQL_USER\": env_vars.DB_USER, \"MYSQL_PASSWORD\": env_vars.DB_PASSWORD}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"PG_HOST\": instance_first_ip_address, \"PG_PORT\": env_vars.PG_PORT, \"PG_DATABASE\": env_vars.PG_DATABASE, \"PG_CONNECTION_NAME\": instance_connection_name}"
                }
              }
            ]
          },
          {
            "name": "gce_container_decl",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "{\"REDIS_HOST\": host, \"REDIS_PORT\": port, \"REDIS_AUTH_STRING\": auth_string}",
                  "inputPath": "env"
                }
              }
            ]
          },
          {
            "name": "service_account",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-composer",
                  "version": ">=6.3.0"
                },
                "spec": {
                  "outputExpr": "service_account.email"
                }
              },
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/datalab/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-pubsub",
    "refTag": "v8.3.2"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "cloud_storage_subscriptions",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"name\": \"gcs-subscription-for-${name}\", \"bucket\": name}"
                }
              }
            ]
          },
          {
            "name": "bigquery_subscriptions",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"name\": \"default-bq-subscription\", \"table\": table_ids[0]}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/pubsub/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-bastion-host",
    "refTag": "v9.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "service_account_roles_supplemental",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/secretmanager.secretAccessor\"]"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "network"
                }
              }
            ]
          },
          {
            "name": "subnet",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "project",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "project_id"
                }
              }
            ]
          },
          {
            "name": "service_account_email",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/bastion-host/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vault",
    "dir": "/",
    "refTag": "v8.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "service_account_project_additional_iam_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-bigtable",
                  "version": ">=0.4.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/bigtable.user\", \"roles/bigtable.reader\", \"roles/bigtable.writer\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/datastore.user\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/alloydb.client\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/cloudsql.client\"]"
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
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              }
            ]
          },
          {
            "name": "subnet",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "vault_instance_metadata",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"POSTGRES_HOST\": instance_first_ip_address, \"POSTGRES_PASSWORD\": generated_user_password, \"POSTGRES_USER\": \"default\", \"POSTGRES_DB\": \"default\"}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vault/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-healthcare",
    "refTag": "v3.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "iam_members",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": iam_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": \"serviceAccount:\" + dataflow_controller_service_account_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.dataViewer\", \"member\": \"serviceAccount:\" + storage_writer_service_account_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-project-factory//modules/project_services",
                  "version": ">=18.0.0"
                },
                "spec": {
                  "outputExpr": "[{ role = \"roles/healthcare.dataViewer\", member = \"serviceAccount:default\" }]"
                }
              }
            ]
          },
          {
            "name": "fhir_stores",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"bq_dataset_id\": dataset_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"notification_configs\": [{\"pubsub_topic\": id}]}"
                }
              }
            ]
          },
          {
            "name": "dicom_stores",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"bq_dataset_id\": dataset_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"notification_config\": {\"pubsub_topic\": id}}"
                }
              }
            ]
          },
          {
            "name": "hl7_v2_stores",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"bq_dataset_id\": dataset_id}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/healthcare/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-healthcare",
    "refTag": "v3.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "iam_members",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": \"serviceAccount:\" + network_name}]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": iam_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-backup-dr",
                  "version": ">=0.5.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": \"serviceAccount:\" + ba_service_account}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.datasetAdmin\", \"member\": \"serviceAccount:\" + dataflow_controller_service_account_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/healthcare.dataViewer\", \"member\": \"serviceAccount:\" + storage_writer_service_account_email}"
                }
              }
            ]
          },
          {
            "name": "hl7_v2_stores",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[{\"rejected_duplicate_message_bucket\": name}]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"notification_configs\": [{\"pubsub_topic\": id}]}"
                }
              }
            ]
          },
          {
            "name": "fhir_stores",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[{\"stream_configs\":[{\"bigquery_destination\":{\"table\":table_fqns[0]}}]}]",
                  "inputPath": "stream_configs.bigquery_destination.table"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"notification_configs\": [{\"pubsub_topic\": id}]}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/healthcare/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-group",
    "refTag": "v0.8.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "members",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "[email]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/group/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-cloud-deploy",
    "refTag": "v0.3.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "trigger_sa_name",
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
          },
          {
            "name": "stage_targets",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "{\n  target_name = cluster_name,\n  target_spec = {\n    \"gke_cluster\" = \"projects/${project_id}/locations/${location}/clusters/${cluster_name}\"\n  }\n}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\n  target_name = service_name,\n  target_type = \"run.googleapis.com/Service\",\n  target_spec = {\n    \"location\" = location\n  }\n}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-deploy/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-cloud-armor",
    "refTag": "v7.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-armor/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-composer",
    "refTag": "v6.3.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "config",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "{\"FIRESTORE_DATABASE_ID\": database_id, \"FIRESTORE_PROJECT_ID\": project_id}",
                  "inputPath": "env_variables"
                }
              }
            ]
          },
          {
            "name": "environment_variables",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-data-fusion",
                  "version": ">=4.1.0"
                },
                "spec": {
                  "outputExpr": "{\"DATA_FUSION_ENDPOINT\": service_endpoint}"
                }
              }
            ]
          },
          {
            "name": "airflow_config_overrides",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"core-sql_alchemy_conn\": \"mysql+pymysql://${env_vars.CLOUD_SQL_USER}:${env_vars.CLOUD_SQL_PASSWORD}@${env_vars.CLOUD_SQL_HOST}:${env_vars.CLOUD_SQL_PORT}/${env_vars.CLOUD_SQL_DATABASE_NAME}\"}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/composer/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-backup-dr",
    "refTag": "v0.5.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "firewall_source_ip_ranges",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"${host}/32\"]"
                }
              }
            ]
          },
          {
            "name": "ba_service_account",
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
          },
          {
            "name": "ba_project_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "data_governance_project_id"
                }
              }
            ]
          },
          {
            "name": "vpc_host_project_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "data_governance_project_id"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/backup-dr/revisions?catalog_template_revision_id=r-1"


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
            "name": "groups",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "{\"group\": instance_group}"
                }
              }
            ]
          },
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
          },
          {
            "name": "security_policy",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-armor",
                  "version": ">=7.0.0"
                },
                "spec": {
                  "outputExpr": "policy"
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
    "repo": "GoogleCloudPlatform/terraform-google-autokey",
    "dir": "/",
    "refTag": "v1.1.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "autokey_folder_users",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "iam_email"
                }
              }
            ]
          },
          {
            "name": "autokey_project_kms_admins",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "iam_email"
                }
              }
            ]
          },
          {
            "name": "autokey_folder_admins",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "iam_email"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/autokey/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-slo",
    "dir": "modules/slo-generator",
    "refTag": "v3.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "pubsub_topic_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "topic"
                }
              }
            ]
          },
          {
            "name": "config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"backend\": {\"type\": \"bigquery\", \"project_id\": bigquery_dataset.project, \"dataset_id\": bigquery_dataset.dataset_id}}"
                }
              }
            ]
          },
          {
            "name": "additional_project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/bigquery.dataViewer\", \"roles/bigquery.jobUser\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[\"roles/monitoring.viewer\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/cloudsql.viewer\"]"
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
              }
            ]
          },
          {
            "name": "bucket_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "name"
                }
              }
            ]
          },
          {
            "name": "slo_configs",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[{\n    \"service_name\": service_name,\n    \"feature_name\": \"requests\",\n    \"slo_id\": \"latency\",\n    \"slo_description\": \"99% of requests return in less than 500ms\",\n    \"slo_target\": 0.99,\n    \"backend\": \"cloud_monitoring\",\n    \"method\": \"good_bad_ratio\",\n    \"good_request_filter\": \"metric.type=\\\"run.googleapis.com/request_latencies\\\" resource.type=\\\"cloud_run_revision\\\" resource.labels.service_name=\\\"{{service_name}}\\\" resource.labels.location=\\\"{{location}}\\\"\",\n    \"bad_request_filter\": \"metric.type=\\\"run.googleapis.com/request_latencies\\\" resource.type=\\\"cloud_run_revision\\\" resource.labels.service_name=\\\"{{service_name}}\\\" resource.labels.location=\\\"{{location}}\\\" distribution_value>500\",\n    \"total_request_filter\": \"metric.type=\\\"run.googleapis.com/request_latencies\\\" resource.type=\\\"cloud_run_revision\\\" resource.labels.service_name=\\\"{{service_name}}\\\" resource.labels.location=\\\"{{location}}\\\"\"\n}]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-operations//modules/simple-uptime-check",
                  "version": ">=0.6.0"
                },
                "spec": {
                  "outputExpr": "[{\"uptime_check_id\": uptime_check_id}]"
                }
              }
            ]
          },
          {
            "name": "service_account_email",
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
          },
          {
            "name": "secrets",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"SLO_CONFIG_SECRET\": {\"secret\": id, \"version\": version}}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/slo-generator/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-sql-db",
    "dir": "modules/mysql",
    "refTag": "v26.2.2"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "ip_configuration",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name",
                  "inputPath": "private_network"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "[{\"name\": \"vpn-network\", \"value\": network}]",
                  "inputPath": "authorized_networks"
                }
              }
            ]
          },
          {
            "name": "iam_users",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"id\": account_details.id, \"email\": account_details.email, \"type\": \"CLOUD_IAM_SERVICE_ACCOUNT\"}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"id\": service_account_id.id, \"email\": service_account_id.email, \"type\": \"CLOUD_IAM_SERVICE_ACCOUNT\"}"
                }
              }
            ]
          },
          {
            "name": "backup_configuration",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"enabled\": true, \"location\": name}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/mysql/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpc-service-controls",
    "dir": "modules/regular_service_perimeter",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "resources",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "[project_number]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-autopilot-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "project_number"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secure-web-proxy",
                  "version": ">=0.1.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_number]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[network_self_link]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "format(\"projects/%s\", split(\"/\", cluster_id)[1])"
                }
              }
            ]
          },
          {
            "name": "restricted_services",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[\"sqladmin.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[\"run.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"redis.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"bigquery.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-bigtable",
                  "version": ">=0.4.1"
                },
                "spec": {
                  "outputExpr": "[\"bigtable.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"secretmanager.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-ids",
                  "version": ">=0.4.0"
                },
                "spec": {
                  "outputExpr": "[\"ids.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "[\"firestore.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[\"storage.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-spanner",
                  "version": ">=1.2.1"
                },
                "spec": {
                  "outputExpr": "[\"spanner.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-node-pool",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "[\"container.googleapis.com\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[\"sqladmin.googleapis.com\"]"
                }
              }
            ]
          },
          {
            "name": "access_levels",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/access_level",
                  "version": ">=7.2.0"
                },
                "spec": {
                  "outputExpr": "[name_id]"
                }
              }
            ]
          },
          {
            "name": "ingress_policies",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\n  from = {\n    identities = [iam_email]\n  }\n}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpc-regular-service-perimeter/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-project-factory",
    "refTag": "v18.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "svpc_host_project_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "project_id"
                }
              }
            ]
          },
          {
            "name": "shared_vpc_subnets",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links"
                }
              }
            ]
          },
          {
            "name": "activate_apis",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "[\"bigquery.googleapis.com\"]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/project-factory/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-endpoints-dns",
    "dir": "/",
    "refTag": "v3.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "external_ip",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-regional-lb-http//modules/frontend",
                  "version": ">=0.6.1"
                },
                "spec": {
                  "outputExpr": "external_ip"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "addresses[0]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-lb-http//modules/frontend",
                  "version": ">=13.2.0"
                },
                "spec": {
                  "outputExpr": "external_ip"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "endpoint"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/endpoints-dns/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-sap",
    "refTag": "v1.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "network"
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
          },
          {
            "name": "sap_nw_nfsserver_ip",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "storage_pool.nfsserver_ip"
                }
              }
            ]
          },
          {
            "name": "sap_nw_ascs_nfs_mount",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "storage_volumes[0].share_name"
                }
              }
            ]
          },
          {
            "name": "sap_nw_ers_nfs_mount",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "storage_volumes[1].share_name"
                }
              }
            ]
          },
          {
            "name": "sap_nw_pas_nfs_mount",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "storage_volumes[2].share_name"
                }
              }
            ]
          },
          {
            "name": "sap_nw_shared_nfs_mount",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "storage_volumes[3].share_name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/sap-nw/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpc-service-controls",
    "dir": "/",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpc-org-policy/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-scheduled-function",
    "refTag": "v8.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "function_environment_variables",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"BUCKET_NAME\": name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_SQL_DATABASE_HOST\" : instance_first_ip_address, \"CLOUD_SQL_DATABASE_CONNECTION_NAME\" : instance_connection_name, \"CLOUD_SQL_DATABASE_NAME\" : env_vars.CLOUD_SQL_DATABASE_NAME, \"CLOUD_SQL_USER_NAME\": env_vars.CLOUD_SQL_USER_NAME, \"CLOUD_SQL_USER_PASSWORD\": env_vars.CLOUD_SQL_USER_PASSWORD}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"BIGQUERY_DATASET_ID\": dataset_id, \"BIGQUERY_TABLE_ID\": table_ids[0]}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"DB_HOST\": instance_first_ip_address, \"CLOUD_SQL_CONNECTION_NAME\": instance_connection_name, \"CLOUD_SQL_DATABASE_NAME\": env_vars.CLOUD_SQL_DATABASE_NAME}"
                }
              }
            ]
          },
          {
            "name": "topic_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "topic"
                }
              }
            ]
          },
          {
            "name": "function_service_account_email",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/scheduled-function/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-bigtable",
    "refTag": "v0.4.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/bigtable/revisions?catalog_template_revision_id=r-1"


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
      "interfaces": {}
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
    "repo": "terraform-google-modules/terraform-google-gke-gitlab",
    "refTag": "v3.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gke-gitlab/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-cloud-operations",
    "dir": "modules/ops-agent-policy",
    "refTag": "v0.6.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "instance_filter",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "{\n\"inclusion_labels\" : [{\n\"labels\" : {\n\"mig_name\" : mig_name\n}\n}]\n}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "{\"inclusion_labels\": [{\"labels\": {\"goog-gke-cluster\": cluster_name}}]}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/ops-agent-policy/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-regional-lb-http",
    "dir": "modules/backend",
    "refTag": "v0.6.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "security_policy",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-armor",
                  "version": ">=7.0.0"
                },
                "spec": {
                  "outputExpr": "policy.self_link"
                }
              }
            ]
          },
          {
            "name": "groups",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "{\"group\": instance_group}"
                }
              }
            ]
          },
          {
            "name": "serverless_neg_backends",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[{\"region\": location, \"type\": \"cloud-run\", \"service_name\": service_name}]"
                }
              }
            ]
          },
          {
            "name": "firewall_networks",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[network_name]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/regional-lb-backend/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-vertex-ai",
    "dir": "modules/workbench",
    "refTag": "v2.3.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network_interfaces",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\"network\": network_name, \"subnet\": subnets_names[0]}"
                }
              }
            ]
          },
          {
            "name": "service_accounts",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "{\"email\": email}"
                }
              }
            ]
          },
          {
            "name": "metadata",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"SECRET_ID\": id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"DB_HOST\": instance_first_ip_address, \"DB_NAME\": env_vars.CLOUD_SQL_DATABASE_NAME, \"DB_USER\": env_vars.CLOUD_SQL_USER, \"DB_PASS\": generated_user_password, \"INSTANCE_CONNECTION_NAME\": instance_connection_name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_SQL_DATABASE_HOST\" : instance_first_ip_address, \"CLOUD_SQL_DATABASE_CONNECTION_NAME\" : instance_connection_name, \"CLOUD_SQL_DATABASE_NAME\" : env_vars.CLOUD_SQL_DATABASE_NAME}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"GCS_BUCKET_NAME\": name}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vertex-workbench/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-address",
    "refTag": "v4.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/address/revisions?catalog_template_revision_id=r-1"


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
    "repo": "GoogleCloudPlatform/terraform-google-cloud-ids",
    "refTag": "v0.4.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "vpc_network_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "network"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-ids/revisions?catalog_template_revision_id=r-1"


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
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_SQL_DATABASE_HOST\" : instance_first_ip_address, \"CLOUD_SQL_DATABASE_CONNECTION_NAME\" : instance_connection_name, \"CLOUD_SQL_DATABASE_NAME\" : env_vars.CLOUD_SQL_DATABASE_NAME}",
                  "inputPath": "env_vars"
                }
              },
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
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "{\"STATIC_IP\": addresses[0]}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-bigtable",
                  "version": ">=0.4.1"
                },
                "spec": {
                  "outputExpr": "{\"BIGTABLE_INSTANCE_ID\": instance_id, \"BIGTABLE_PROJECT_ID\": project_id}",
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
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "{\"REDIS_HOST\": host, \"REDIS_PORT\": port, \"REDIS_AUTH_STRING\": auth_string}",
                  "inputPath": "env_vars"
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
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "{\"ALLOYDB_HOST\": primary_instance_ip, \"ALLOYDB_INSTANCE_ID\": primary_instance_id}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"PUBSUB_TOPIC_NAME\": topic}",
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
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "{\"FIRESTORE_DATABASE_ID\": database_id}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-spanner",
                  "version": ">=1.2.1"
                },
                "spec": {
                  "outputExpr": "{\"SPANNER_INSTANCE_ID\": spanner_instance_id, \"SPANNER_DATABASE_ID\": keys(spanner_db_details)[0]}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source":  {
                  "source":  "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version":  ">=0.21.6"
                },
                "spec":  {
                  "outputExpr":  "{\"SERVICE_ENDPOINT\": service_uri}",
                  "inputPath":  "env_vars"
                }
              }
            ]
          },
          {
            "name": "service_account_project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-bigtable",
                  "version": ">=0.4.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/bigtable.user\"]"
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
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/redis.client\"]"
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
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/alloydb.client\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/compute.networkUser\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/pubsub.publisher\", \"roles/pubsub.subscriber\", \"roles/run.invoker\"]"
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
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/datastore.user\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-deploy",
                  "version": ">=0.3.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/clouddeploy.jobRunner\", \"roles/clouddeploy.viewer\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-spanner",
                  "version": ">=1.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/spanner.databaseUser\"]"
                }
              }
            ]
          },
          {
            "name": "vpc_access",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\"network_interfaces\": {\"network\": network_name}}"
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
    "repo": "terraform-google-modules/terraform-google-cloud-operations",
    "dir": "modules/simple-uptime-check",
    "refTag": "v0.6.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "monitored_resource",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "{\"monitored_resource_type\": \"uptime_url\", \"labels\": {\"host\": endpoint}}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-lb-http//modules/frontend",
                  "version": ">=13.2.0"
                },
                "spec": {
                  "outputExpr": "{\"monitored_resource_type\": \"uptime_url\", \"labels\": {\"host\": external_ip}}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"labels\": {\"host\": service_uri}, \"monitored_resource_type\": \"uptime_url\"}"
                }
              }
            ]
          },
          {
            "name": "notification_channels",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"type\": \"pubsub\", \"display_name\": \"Uptime Alert pub/sub channel\", \"labels\": {\"topic\": id}}"
                }
              }
            ]
          },
          {
            "name": "protocol",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "\"HTTPS\""
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/ops-simple-uptime-check/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vm",
    "dir": "modules/instance_template",
    "refTag": "v13.5.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "metadata",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-container-vm",
                  "version": ">=3.2.0"
                },
                "spec": {
                  "outputExpr": "{[metadata_key]: metadata_value}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"GCS_BUCKET_NAME\": name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "{\"REDIS_HOST\": host, \"REDIS_PORT\": port, \"REDIS_AUTH_STRING\": auth_string}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"SECRET_ID\": id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"DB_HOST\": instance_first_ip_address, \"DB_CONNECTION_NAME\": instance_connection_name, \"DB_NAME\": env_vars.db_name}"
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
                  "outputExpr": "{\"email\": email, \"scopes\": [\"cloud-platform\"]}"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              }
            ]
          },
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "service_account_project_roles",
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
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-operations//modules/ops-agent-policy",
                  "version": ">=0.6.0"
                },
                "spec": {
                  "outputExpr": "[\"roles/monitoring.metricWriter\", \"roles/logging.logWriter\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gce-instance-template/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-cloud-spanner",
    "refTag": "v1.2.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/spanner/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-event-function",
    "refTag": "v6.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "environment_variables",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\n\"DB_HOST\": instance_first_ip_address,\n\"DB_CONNECTION_NAME\": instance_connection_name,\n\"DB_NAME\": env_vars.db_name\n}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-bigtable",
                  "version": ">=0.4.1"
                },
                "spec": {
                  "outputExpr": "{\"BIGTABLE_INSTANCE_ID\": instance_id, \"PROJECT_ID\": project_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "{\"ALLOYDB_HOST\": primary_instance_ip}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"DB_HOST\": instance_first_ip_address, \"DB_CONNECTION_NAME\": instance_connection_name, \"DB_NAME\": env_vars.db_name, \"DB_USER\": env_vars.user_name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"GCP_PROJECT\": project, \"BIGQUERY_DATASET\": dataset_id, \"BIGQUERY_TABLE\": table_ids[0]}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "{\"REDIS_HOST\": host, \"REDIS_PORT\": port}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "{\"CLOUD_RUN_ENDPOINT\": service_uri}"
                }
              }
            ]
          },
          {
            "name": "service_account_email",
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
          },
          {
            "name": "event_trigger",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"event_type\": \"google.cloud.storage.object.v1.finalized\", \"resource\": name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"resource\": id, \"event_type\": \"google.pubsub.topic.publish\"}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "{\"event_type\": \"google.cloud.firestore.document.v1.written\", \"resource\": database_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-scheduled-function",
                  "version": ">=8.0.0"
                },
                "spec": {
                  "outputExpr": "{\"event_type\": \"google.pubsub.topic.publish\", \"resource\": pubsub_topic_name}"
                }
              }
            ]
          },
          {
            "name": "service_account_project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/redis.client\"]"
                }
              }
            ]
          },
          {
            "name": "secret_environment_variables",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[{\"key\": \"MY_SECRET\", \"secret_name\": name, \"version\": version}]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/event-function/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-cloud-router",
    "dir": "/",
    "refTag": "v8.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "nats",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "{\"name\": \"my-nat-gateway\", \"nat_ips\": self_links, \"source_subnetwork_ip_ranges_to_nat\": \"ALL_SUBNETWORKS_ALL_IP_RANGES\"}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-router/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-project-factory",
    "dir": "modules/project_services",
    "refTag": "v18.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "activate_api_identities",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"api\": \"secretmanager.googleapis.com\", \"roles\": [\"roles/secretmanager.secretAccessor\"]}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "[{\"api\": \"pubsub.googleapis.com\", \"roles\": [\"roles/pubsub.editor\"]}]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-vertex-ai//modules/feature-online-store",
                  "version": ">=2.3.1"
                },
                "spec": {
                  "outputExpr": "[{ api = \"aiplatform.googleapis.com\", roles = [\"roles/aiplatform.user\"] }]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vertex-ai/revisions?catalog_template_revision_id=r-1"


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
      "interfaces": {}
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
    "repo": "terraform-google-modules/terraform-google-cloud-router",
    "dir": "modules/interconnect_attachment",
    "refTag": "v8.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "router",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-router",
                  "version": ">=8.1.0"
                },
                "spec": {
                  "outputExpr": "router.name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-router-interconnect-attachment/revisions?catalog_template_revision_id=r-1"


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
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"PUB_SUB_TOPIC_ID\": id}",
                  "inputPath": "environment_variables"
                }
              },
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
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "{\"FIRESTORE_DATABASE\": database_id}",
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
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/pubsub.publisher\", \"roles/pubsub.subscriber\"]",
                  "inputPath": "roles"
                }
              },
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
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/datastore.user\"]",
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
          },
          {
            "name": "address",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "addresses[0]"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
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
    "repo": "GoogleCloudPlatform/terraform-google-secured-data-warehouse",
    "refTag": "v0.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "trusted_subnetworks",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links"
                }
              }
            ]
          },
          {
            "name": "bucket_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "name"
                }
              }
            ]
          },
          {
            "name": "additional_restricted_services",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-ids",
                  "version": ">=0.4.0"
                },
                "spec": {
                  "outputExpr": "[\"ids.googleapis.com\"]"
                }
              }
            ]
          },
          {
            "name": "data_ingestion_dataflow_deployer_identities",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-data-fusion",
                  "version": ">=4.1.0"
                },
                "spec": {
                  "outputExpr": "[\"serviceAccount:${instance.service_account}\"]"
                }
              }
            ]
          },
          {
            "name": "confidential_data_dataflow_deployer_identities",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-data-fusion",
                  "version": ">=4.1.0"
                },
                "spec": {
                  "outputExpr": "[\"serviceAccount:${instance.service_account}\"]"
                }
              }
            ]
          },
          {
            "name": "terraform_service_account",
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
          },
          {
            "name": "perimeter_additional_members",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "[iam_email]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bastion-host",
                  "version": ">=9.0.0"
                },
                "spec": {
                  "outputExpr": "[\"serviceAccount:${service_account}\"]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/secured-data-warehouse/revisions?catalog_template_revision_id=r-1"


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
        "variables": [
          {
            "name": "iam_members",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-backup-dr",
                  "version": ">=0.5.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/storage.objectAdmin\", \"member\": \"serviceAccount:\".concat(ba_service_account)}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/storage.objectAdmin\", \"member\": \"serviceAccount:${storage_writer_service_account_email}\"}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gcs-storage/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-alloy-db",
    "refTag": "v8.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network_self_link",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              }
            ]
          },
          {
            "name": "cluster_initial_user",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"password\": id}"
                }
              }
            ]
          },
          {
            "name": "authorized_external_principals",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "[{\n    \"principal\": format(\"principalSet://iam.googleapis.com/%s\", workload_identity_config.workload_pool),\n    \"type\": \"WORKLOAD_IDENTITY_POOL\"\n}]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/alloydb/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-vertex-ai",
    "dir": "modules/feature-online-store",
    "refTag": "v2.3.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "psc_project_allowlist",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/gke-standard-cluster",
                  "version": ">=41.0.1"
                },
                "spec": {
                  "outputExpr": "[project_id]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vertex-feature-online-store/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-folders",
    "refTag": "v5.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "all_folder_admins",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-group",
                  "version": ">=0.8.0"
                },
                "spec": {
                  "outputExpr": "\"group:\" + id"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/folders/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpc-service-controls",
    "dir": "modules/access_level",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "vpc_network_sources",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\n\"network_name\": {\n\"network_id\": network_name\n}\n}"
                }
              }
            ]
          },
          {
            "name": "members",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "iam_email"
                }
              }
            ]
          },
          {
            "name": "policy",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpc-service-controls",
                  "version": ">=7.2.0"
                },
                "spec": {
                  "outputExpr": "policy_name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpc-access-level/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpc-service-controls",
    "dir": "modules/bridge_service_perimeter",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "resources",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "[\n  project_id\n]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpc-service-controls//modules/regular_service_perimeter",
                  "version": ">=7.2.0"
                },
                "spec": {
                  "outputExpr": "perimeter_name"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "[\"projects/\" + project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-run//modules/v2",
                  "version": ">=0.21.6"
                },
                "spec": {
                  "outputExpr": "[project_id]"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[project_id]"
                }
              }
            ]
          },
          {
            "name": "restricted_services",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[\"secretmanager.googleapis.com\"]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpc-bridge-service-perimeter/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-memorystore",
    "refTag": "v15.2.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "authorized_network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/redis-memorystore/revisions?catalog_template_revision_id=r-1"


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
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-data-fusion",
                  "version": ">=4.1.0"
                },
                "spec": {
                  "outputExpr": "[{\"role\": \"roles/bigquery.dataEditor\", \"userByEmail\": instance.service_account}, {\"role\": \"roles/bigquery.jobUser\", \"userByEmail\": instance.service_account}]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/bigquery.dataEditor\", \"userByEmail\": dataflow_controller_service_account_email}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secured-data-warehouse",
                  "version": ">=0.2.0"
                },
                "spec": {
                  "outputExpr": "{\"role\": \"roles/bigquery.dataWriter\", \"userByEmail\": pubsub_writer_service_account_email}"
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
    "repo": "GoogleCloudPlatform/terraform-google-netapp-volumes",
    "refTag": "v2.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "storage_volumes",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "name",
                  "inputPath": "kerberos_key_secret_name"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "name",
                  "inputPath": "cifs_ad_domain_password_secret_name"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "name",
                  "inputPath": "dns_ad_domain_password_secret_name"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-backup-dr",
                  "version": ">=0.5.0"
                },
                "spec": {
                  "outputExpr": "ba_randomised_name",
                  "inputPath": "backup_vault"
                }
              }
            ]
          },
          {
            "name": "storage_pool",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\"network_name\": network_name, \"network_project_id\": project_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "network",
                  "inputPath": "network_name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/netapp-volumes/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-cloud-router",
    "dir": "modules/interface",
    "refTag": "v8.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "interconnect_attachment",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-router//modules/interconnect_attachment",
                  "version": ">=8.1.0"
                },
                "spec": {
                  "outputExpr": "attachment.self_link"
                }
              }
            ]
          },
          {
            "name": "router",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-router",
                  "version": ">=8.1.0"
                },
                "spec": {
                  "outputExpr": "router.name"
                }
              }
            ]
          },
          {
            "name": "vpn_tunnel",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "vpn_tunnels_self_link-dynamic"
                }
              }
            ]
          },
          {
            "name": "peers",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "{\"peer_ip_address\": addresses[0]}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/cloud-router-interface/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-container-vm",
    "dir": "/",
    "refTag": "v3.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "container",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-memorystore",
                  "version": ">=15.2.1"
                },
                "spec": {
                  "outputExpr": "{\"REDIS_HOST\": host, \"REDIS_PORT\": port, \"REDIS_AUTH_STRING\": auth_string}",
                  "inputPath": "env_vars"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"POSTGRES_HOST\": instance_first_ip_address, \"POSTGRES_CONNECTION_NAME\": instance_connection_name, \"POSTGRES_DB\": env_vars.db_name}",
                  "inputPath": "env"
                }
              }
            ]
          },
          {
            "name": "volumes",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-netapp-volumes",
                  "version": ">=2.1.0"
                },
                "spec": {
                  "outputExpr": "[{\"name\": storage_volumes[0].name, \"driver\": \"local\", \"driver_opts\": {\"type\": \"nfs\", \"o\": \"addr=\" + storage_volumes[0].mount_points[0].server_ip + \",rw\", \"device\": \":\" + storage_volumes[0].mount_points[0].export_point}}]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/container-vm/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-firestore",
    "refTag": "v0.2.2"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/firestore/revisions?catalog_template_revision_id=r-1"


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
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/secret-manager/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-vpn",
    "refTag": "v6.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "vpn_gw_ip",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "addresses[0]"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "cr_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-router",
                  "version": ">=8.1.0"
                },
                "spec": {
                  "outputExpr": "router.name"
                }
              }
            ]
          },
          {
            "name": "shared_secret",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "id"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/vpn/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-pam",
    "refTag": "v3.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "role_bindings",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "[{\"role\": \"roles/cloudsql.admin\"}]"
                }
              }
            ]
          },
          {
            "name": "entitlement_requesters",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-group",
                  "version": ">=0.8.0"
                },
                "spec": {
                  "outputExpr": "id"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "[email]"
                }
              }
            ]
          },
          {
            "name": "entitlement_approvers",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-group",
                  "version": ">=0.8.0"
                },
                "spec": {
                  "outputExpr": "id"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/pam/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-tf-cloud-agents",
    "dir": "modules/tfc-agent-mig-container-vm",
    "refTag": "v0.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "subnet_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_names[0]"
                }
              }
            ]
          },
          {
            "name": "project_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "project_id"
                }
              }
            ]
          },
          {
            "name": "subnetwork_project",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "project_id"
                }
              }
            ]
          },
          {
            "name": "additional_metadata",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-container-vm",
                  "version": ">=3.2.0"
                },
                "spec": {
                  "outputExpr": "{ [metadata_key] = metadata_value }"
                }
              }
            ]
          },
          {
            "name": "service_account_email",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/tfc-agent-mig-container-vm/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-kubernetes-engine",
    "dir": "modules/gke-standard-cluster",
    "refTag": "v41.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "node_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "email",
                  "inputPath": "service_account"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "version",
                  "inputPath": "containerd_config.private_registry_access_config.certificate_authority_domain_config.gcp_secret_manager_certificate_config.secret_uri"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "[\"https://www.googleapis.com/auth/devstorage.read_write\"]",
                  "inputPath": "oauth_scopes"
                }
              }
            ]
          },
          {
            "name": "ip_allocation_policy",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "names[0]",
                  "inputPath": "cluster_secondary_range_name"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "names[0]",
                  "inputPath": "services_secondary_range_name"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\n  cluster_secondary_range_name = secondary_ranges[subnets[0].subnet_name][0].range_name\n}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "{\n  services_secondary_range_name = secondary_ranges[subnets[0].subnet_name][1].range_name\n}"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              }
            ]
          },
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "notification_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"pubsub\": {\"enabled\": true, \"topic\": id}}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gke-standard-cluster/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-github-actions-runners",
    "refTag": "v5.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "subnetwork_name",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_names[0]"
                }
              }
            ]
          },
          {
            "name": "service_account_email",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gh-runner-mig-vm/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-kubernetes-engine",
    "dir": "modules/gke-autopilot-cluster",
    "refTag": "v41.0.1"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vpn",
                  "version": ">=6.1.0"
                },
                "spec": {
                  "outputExpr": "network"
                }
              }
            ]
          },
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "secret_manager_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"enabled\": true}"
                }
              }
            ]
          },
          {
            "name": "project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/alloydb.client\"]"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-cloud-spanner",
                  "version": ">=1.2.1"
                },
                "spec": {
                  "outputExpr": "[\"roles/spanner.databaseUser\"]"
                }
              }
            ]
          },
          {
            "name": "service_account_project_roles",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "[\"roles/datastore.user\"]"
                }
              }
            ]
          },
          {
            "name": "cluster_autoscaling",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-service-accounts//modules/simple-sa",
                  "version": ">=4.6.0"
                },
                "spec": {
                  "outputExpr": "email",
                  "inputPath": "auto_provisioning_defaults.service_account"
                }
              }
            ]
          },
          {
            "name": "notification_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"pubsub\": {\"enabled\": true, \"topic\": topic}}"
                }
              }
            ]
          },
          {
            "name": "resource_usage_export_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\n \"enable_resource_consumption_metering\": true,\n \"bigquery_destination\": {\n  \"dataset_id\": bigquery_dataset.dataset_id\n }\n}"
                }
              }
            ]
          },
          {
            "name": "ip_allocation_policy",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "names[0]",
                  "inputPath": "cluster_secondary_range_name"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "names[0]",
                  "inputPath": "services_secondary_range_name"
                }
              }
            ]
          },
          {
            "name": "master_authorized_networks_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "{\"display_name\": \"Static IP for master access\", \"cidr_block\": addresses[0] + \"/32\"}",
                  "inputPath": "cidr_blocks"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/gke-autopilot-cluster/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-media-cdn-vod",
    "refTag": "v0.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/media-cdn-vod/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-secure-web-proxy",
    "refTag": "v0.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_self_link"
                }
              }
            ]
          },
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_self_links[0]"
                }
              }
            ]
          },
          {
            "name": "certificate_urls",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "[id]"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/secure-web-proxy/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-regional-lb-http",
    "dir": "modules/frontend",
    "refTag": "v0.6.1"
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
                  "source": "github.com/GoogleCloudPlatform/terraform-google-regional-lb-http//modules/backend",
                  "version": ">=0.6.1"
                },
                "spec": {
                  "outputExpr": "backend_service_info"
                }
              }
            ]
          },
          {
            "name": "address",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "addresses[0]"
                }
              }
            ]
          },
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/regional-lb-frontend/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-org-policy",
    "refTag": "v7.2.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "allow",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-autokey",
                  "version": ">=1.1.1"
                },
                "spec": {
                  "outputExpr": "[\"projects/\".concat(key_project_id)]"
                }
              }
            ]
          },
          {
            "name": "folder_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-folders",
                  "version": ">=5.1.0"
                },
                "spec": {
                  "outputExpr": "id"
                }
              }
            ]
          },
          {
            "name": "policy_for",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-folders",
                  "version": ">=5.1.0"
                },
                "spec": {
                  "outputExpr": "\"folder\""
                }
              }
            ]
          },
          {
            "name": "project_id",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-project-factory",
                  "version": ">=18.2.0"
                },
                "spec": {
                  "outputExpr": "project_id"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/org-policy/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-data-fusion",
    "refTag": "v4.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "options",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-firestore",
                  "version": ">=0.2.2"
                },
                "spec": {
                  "outputExpr": "{\"project\": project_id, \"datasetProject\": project_id, \"dataset\": database_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-alloy-db",
                  "version": ">=8.0.1"
                },
                "spec": {
                  "outputExpr": "{\"ALLOYDB_HOST\": primary_instance_ip}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket",
                  "version": ">=12.0.0"
                },
                "spec": {
                  "outputExpr": "{\"GCS_BUCKET_NAME\": name}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/mysql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\"DB_HOST\": instance_first_ip_address, \"DB_CONNECTION_NAME\": instance_connection_name, \"DB_NAME\": env_vars.CLOUD_SQL_DATABASE_NAME}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-bigquery",
                  "version": ">=10.2.1"
                },
                "spec": {
                  "outputExpr": "{\"BIGQUERY_PROJECT\": project, \"BIGQUERY_DATASET\": bigquery_dataset.dataset_id}"
                }
              },
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-pubsub",
                  "version": ">=8.3.2"
                },
                "spec": {
                  "outputExpr": "{\"pubsub_topic_name\": topic}"
                }
              },
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"SECRET_ID\": id}"
                }
              }
            ]
          },
          {
            "name": "database_connection",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql",
                  "version": ">=26.2.2"
                },
                "spec": {
                  "outputExpr": "{\n \"database\": env_vars.CLOUD_SQL_DATABASE_NAME,\n \"host\": instance_first_ip_address,\n \"port\": env_vars.CLOUD_SQL_DATABASE_PORT\n}"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/data-fusion/revisions?catalog_template_revision_id=r-1"


curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-network",
    "refTag": "v13.0.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {}
    }
  },
  "templateCategory": "COMPONENT_TEMPLATE"
}' \
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/network/revisions?catalog_template_revision_id=r-1"

curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "terraform-google-modules/terraform-google-lb-internal",
    "dir": "/",
    "refTag": "v7.1.0"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "network",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "network_name"
                }
              }
            ]
          },
          {
            "name": "subnetwork",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "subnets_names[0]"
                }
              }
            ]
          },
          {
            "name": "network_project",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-network",
                  "version": ">=13.0.0"
                },
                "spec": {
                  "outputExpr": "project_id"
                }
              }
            ]
          },
          {
            "name": "backends",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-vm//modules/mig",
                  "version": ">=13.6.1"
                },
                "spec": {
                  "outputExpr": "[{\"group\": instance_group}]"
                }
              }
            ]
          },
          {
            "name": "ip_address",
            "connections": [
              {
                "source": {
                  "source": "github.com/terraform-google-modules/terraform-google-address",
                  "version": ">=4.2.0"
                },
                "spec": {
                  "outputExpr": "addresses[0]"
                }
              }
            ]
          },
          {
            "name": "source_service_accounts",
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
          },
          {
            "name": "target_service_accounts",
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/internal-load-balancer/revisions?catalog_template_revision_id=r-1"

curl -X POST -i \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  --data '{
  "gitSource": {
    "repo": "GoogleCloudPlatform/terraform-google-artifact-registry",
    "dir": "/",
    "refTag": "v0.8.2"
  },
  "metadataInput": {
    "spec": {
      "interfaces": {
        "variables": [
          {
            "name": "remote_repository_config",
            "connections": [
              {
                "source": {
                  "source": "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret",
                  "version": ">=0.9.0"
                },
                "spec": {
                  "outputExpr": "{\"username\": \"some_user\", \"password_secret_version\": id}",
                  "inputPath": "upstream_credentials"
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
  "https://designcenter.googleapis.com/v1alpha/projects/$PROJECT_ID/locations/us-central1/spaces/$SPACE_ID/catalogs/$CATALOG_ID/templates/artifact-registry/revisions?catalog_template_revision_id=r-1"

