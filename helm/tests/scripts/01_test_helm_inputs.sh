#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --case)
      case="$2"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# cluster name
clusterName="my-dope-cluster"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nrotelk8s"
otelcollectors["namespace"]="monitoring"

### Case 01 - Cluster name should be defined
if [[ $case == "01" ]]; then
  msg="ERROR: Cluster name should be defined!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 02 - At least 1 telemetry type should be enabled
if [[ $case == "02" ]]; then
  msg="ERROR: At least one of the following must be enabled: traces, logs & metrics!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 03, 04, 05 - New Relic account should be defined

# Deployment
if [[ $case == "03" ]]; then
  msg="ERROR \[DEPLOYMENT\]: You have enabled traces but haven't defined any New Relic account neither in the global section nor in the deployment section to send the data to!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams=null \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "04" ]]; then
  msg="ERROR \[DAEMONSET\]: You have enabled logs but haven't defined any New Relic account neither in the global section nor in the daemonset section to send the data to!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams=null \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "05" ]]; then
  msg="ERROR \[STATEFULSET\]: You have enabled metrics but haven't defined any New Relic account neither in the global section nor in the statefulet section to send the data to!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams=null \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 06, 07, 08 - OTLP endpoint should be valid (global)

# Deployment
if [[ $case == "06" ]]; then
  msg="ERROR \[DEPLOYMENT\]: The given global OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "07" ]]; then
  msg="ERROR \[DAEMONSET\]: The given global OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "08" ]]; then
  msg="ERROR \[STATEFULSET\]: The given global OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 09, 10, 11 - OTLP endpoint should be valid (individual)

# Deployment
if [[ $case == "09" ]]; then
  msg="ERROR \[DEPLOYMENT\]: The given OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "10" ]]; then
  msg="ERROR \[DAEMONSET\]: The given OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "11" ]]; then
  msg="ERROR \[STATEFULSET\]: The given OTLP enpoint is incorrect. Valid values: For US -> otlp.nr-data.net:4317 or for EU -> otlp.eu01.nr-data.net:4317"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 12, 13, 14 - License key should be defined (global)

# Deployment
if [[ $case == "12" ]]; then
  msg="ERROR \[DEPLOYMENT\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "13" ]]; then
  msg="ERROR \[DAEMONSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "14" ]]; then
  msg="ERROR \[STATEFULSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 15, 16, 17 - License key should be defined (individual)

# Deployment
if [[ $case == "15" ]]; then
  msg="ERROR \[DEPLOYMENT\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "16" ]]; then
  msg="ERROR \[DAEMONSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "17" ]]; then
  msg="ERROR \[STATEFULSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 18, 19, 20 - License key reference should have a name (global)

# Deployment
if [[ $case == "18" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "19" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "20" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 21, 22, 23 - License key reference should have a name (individual)

# Deployment
if [[ $case == "21" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "22" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "23" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 24, 25, 26 - License key reference should have a key (global)

# Deployment
if [[ $case == "24" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "25" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "26" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

### Case 27, 28, 29 - License key reference should have a key (individual)

# Deployment
if [[ $case == "27" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Daemonset
if [[ $case == "28" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set metrics.enabled=false \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi

# Statefulset
if [[ $case == "29" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    "../../charts/collectors" \
    2>&1 | grep "$msg")

    if [[ $result == "" ]]; then
      echo "Failed"
      exit 1
    else
      echo "Test successful. Error message is captured -> $result"
    fi
fi
