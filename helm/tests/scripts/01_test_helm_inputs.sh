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
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 02 - At least 1 telemetry type should be enabled
if [[ $case == "02" ]]; then
  msg="ERROR: At least one of the following must be enabled: traces, logs, metrics & events!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

  echo "$result"

  check=$(echo "$result" | grep "$msg")
  if [[ $check == "" ]]; then
    echo "Test failed. Expected error message is not captured."
    exit 1
  else
    echo "Test successful. Expected error message is captured."
  fi
fi

### Case 03, 04, 05, 06 - New Relic account should be defined

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
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
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
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
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
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "06" ]]; then
  msg="ERROR \[SINGLETON\]: You have enabled events but haven't defined any New Relic account neither in the global section nor in the singleton section to send the data to!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.teams=null \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 07, 08, 09, 10 - OTLP endpoint should be valid (global)

# Deployment
if [[ $case == "07" ]]; then
  msg="ERROR \[DEPLOYMENT\]: The given global OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "08" ]]; then
  msg="ERROR \[DAEMONSET\]: The given global OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "09" ]]; then
  msg="ERROR \[STATEFULSET\]: The given global OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "10" ]]; then
  msg="ERROR \[SINGLETON\]: The given global OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 11, 12, 13, 14 - OTLP endpoint should be valid (individual)

# Deployment
if [[ $case == "11" ]]; then
  msg="ERROR \[DEPLOYMENT\]: The given OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "12" ]]; then
  msg="ERROR \[DAEMONSET\]: The given OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "13" ]]; then
  msg="ERROR \[STATEFULSET\]: The given OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "14" ]]; then
  msg="ERROR \[SINGLETON\]: The given OTLP enpoint is incorrect. Valid values: For US -> https://otlp.nr-data.net or for EU -> https://otlp.eu01.nr-data.net"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.teams.opsteam.endpoint="INVALID_ENDPOINT" \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 15, 16, 17, 18 - License key should be defined (global)

# Deployment
if [[ $case == "15" ]]; then
  msg="ERROR \[DEPLOYMENT\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "16" ]]; then
  msg="ERROR \[DAEMONSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "17" ]]; then
  msg="ERROR \[STATEFULSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "18" ]]; then
  msg="ERROR \[SINGLETON\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi


### Case 19, 20, 21, 22 - License key should be defined (individual)

# Deployment
if [[ $case == "19" ]]; then
  msg="ERROR \[DEPLOYMENT\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "20" ]]; then
  msg="ERROR \[DAEMONSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "21" ]]; then
  msg="ERROR \[STATEFULSET\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "22" ]]; then
  msg="ERROR \[SINGLETON\]: Neither a license key secret is referenced nor the value of the license key is provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.opsteam.endpoint="https://otlp.nr-data.net" \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 23, 24, 25, 26 - License key reference should have a name (global)

# Deployment
if [[ $case == "23" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "24" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "25" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "26" ]]; then
  msg="ERROR \[SINGLETON\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 27, 28, 29, 30 - License key reference should have a name (individual)

# Deployment
if [[ $case == "27" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set deployment.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "28" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set daemonset.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "29" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "30" ]]; then
  msg="ERROR \[SINGLETON\]: License key is referenced but its name is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set singleton.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 31, 32, 33, 34 - License key reference should have a key (global)

# Deployment
if [[ $case == "31" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "32" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "33" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "34" ]]; then
  msg="ERROR \[SINGLETON\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="https://otlp.nr-data.net" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

### Case 35, 36, 37, 38 - License key reference should have a key (individual)

# Deployment
if [[ $case == "35" ]]; then
  msg="ERROR \[DEPLOYMENT\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set deployment.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Daemonset
if [[ $case == "36" ]]; then
  msg="ERROR \[DAEMONSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set daemonset.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set metrics.enabled=false \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Statefulset
if [[ $case == "37" ]]; then
  msg="ERROR \[STATEFULSET\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set events.enabled=false \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi

# Singleton
if [[ $case == "38" ]]; then
  msg="ERROR \[SINGLETON\]: License key is referenced but the key to the license key within the secret is not provided!"

  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    --set events.enabled=true \
    --set singleton.newrelic.teams.opsteam.endpoint="https://otlp.nr-data.net" \
    --set singleton.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    "../../charts/collectors" \
    2>&1)

    echo "$result"

    check=$(echo "$result" | grep "$msg")
    if [[ $check == "" ]]; then
      echo "Test failed. Expected error message is not captured."
      exit 1
    else
      echo "Test successful. Expected error message is captured."
    fi
fi