# Understanding Cost Analysis

There is a pre-built cost analysis functionality for you so that you can easily start understanding how well you are utilizing your underlying infrastructure in a financial perspective.

To have such monitoring, we obviously need to know the unit price per hour of the underlying VMs where the unit price depends on the following parameters:

- Cloud provider
- Cloud region (datacenter)
- VM type (SKU)

Luckily, the Open Telemetry collector has the `resourcedetectionprocessor` which determines these parameters for us (see [docs](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/resourcedetectionprocessor)) and enrichs the telemetry data.

Now, we know exactly which telemetry data is coming from what sort a VM and thereby we know the cost of that VM per hour. Here is how we can leverage that to have deeper comprehension of our clusters.

## Cost analysis for nodes

When you select a VM for a node group in your cluster, you will going to pay for various parameters as CPU, MEM, STO... In our calculation, we only consider the CPU and the MEM.

So, when you select and run a VM, you are going to pay for the full price of that VM regardless whether you will use it to the fullest or not. Our starting point of defining _"What is a loss of money?"_ lies in the following complete edge cases in an operational sense:

- when you utilize both the CPU and the MEM to the fullest, you are getting the most out of your VM and therefore do not lose any money.
- when you utilize none the CPU and the MEM, you are getting nothing out of your VM and therefore lose all the money you spend.
- when you utilize the CPU to the fullest but none of the MEM or vice versa, you are getting the half of the value and thereby lose half of your money.

That being said, we can assume to make the calculation both for CPU and MEM independently with a proportion coefficient of `1/2` as if each one of them represent the half of the unit price.

```
CPU
moneyLoss [$/hour] = idleCpu [vcores] * (price [$/hour] * cpuProportion [1/2] / totalCpu [vcores])

MEM
moneyLoss [$/hour] = freeMemory [GB] * (price [$/hour] * memoryProportion [1/2] / totalMemory [GB])
```

Let's make an example. Let's assume that you have a VM with `2 vcores` and `8 GB` of memory which costs 2.00$ per hour. According to the calculation method, you pay `1.00$` for `2 vcores` of CPU and `1.00$` for the `8 GB` of MEM per hour.

If you are utilizing `1 vcore` and `4 GB` per hour,

```
CPU
moneyLoss [$/hour] = (2 - 1) [vcores] * (2.00 [$/hour] * 0.5 / 2 [vcores]) = 0.50 [$/hour]

MEM
moneyLoss [$/hour] = (8 - 4) [GB] * (2.00 [$/hour] * 0.5 / 8 [GB]) = 0.50 [$/hour]
```

you are losing `1.00$` per hour due to not utilizing your VM to the fullest. You can simply act accordingly!

- If you benefit neither from CPU or MEM, simply scale down your VM or shutdown some of the VMs within a node group.
- If you benefit from CPU but not from MEM, choose a CPU optimized VM.
- If you benefit from MEM but not from CPU, choose a MEM optimized VM.

## Cost analysis for namespaces and pods

The cost calculation for the workloads is a little bit trickier. Let's start with how much a workload actually costs for you. If your workload does not use any CPU or MEM, it basically costs you nothing. **DON'T WORRY!** We will talk about reserved _(or technically speaking: requested)_ resources below!.

Since, we assumed that the costs for CPU and MEM are representing the half of the total VM cost, we can continue to consider that the workloads as well. The difference between nodes and workloads is that we will be evaluating the workload costs in 6 hours of intervals. The reason for that is that there might be a ton of pods and containers in a cluster and calculating the price per hour might cause that we exceed the limitations of NRQL.

```
CPU
actualCost [$/6hour] = 6 * price [$/6hour] * cpuProportion [1/2] * (usedCpu [vcores] / totalCpu [vcores])

MEM
actualCost [$/6hour] = 6 * price [$/6hour] * memProportion [1/2] * (usedMemory [GB] / totalMemory [GB])
```

Let's continue with the node example above. If your workload is using `0.5 vcores` of CPU and `1 GB` of MEM,

```
CPU
actualCost [$/6hour] = 6 * 2.00 [$/6hour] * 0.5 * (0.5 [vcores] / 2 [vcores]) = 1.5 [$/6hour] -> 0.25 [$/hour]

MEM
actualCost [$/6hour] = 6 * 2.00 [$/6hour] * 0.5 * (1 [GB] / 8 [GB]) = 0.75 [$/6hour] -> 0.125 [$/1hour]
```

your workload is actually costing you `0.375$` per hour.

So what about what you hav requested for your workloads? What if you are using `0.5 vcores` of CPU and `1 GB` of MEM, but you have requested `1 vcore` of CPU and `1.5 GB` of MEM? Obviously, you are blocking your other workloads to use that free space in your VM which causes you to lose money. Let's dive in to that as well.

```
CPU
actualCost [$/6hour] = 6 * price [$/6hour] * cpuProportion [1/2] * ((requestedCpu [vcores] - usedCpu [vcores]) / totalCpu [vcores])

MEM
actualCost [$/6hour] = 6 * price [$/6hour] * memProportion [1/2] * ((requestedMemory [GB] - usedMemory [GB]) / totalMemory [GB])
```

Let's put the requested resources into the equation:

```
CPU
actualCost [$/6hour] = 6 * 2.00 [$/6hour] * 0.5 * ((1 [vcores] - 0.5 [vcores]) / 2 [vcores]) = 1.50 [$/6hour] -> 0.25 [$/1hour]

MEM
actualCost [$/6hour] = 6 * 2.00 [$/6hour] * 0.5 * ((1.5 [GB] - 1 [GB]) / 8 [GB]) = 0.375 [$/6hour] -> 0.0625 [$/1hour]
```

your workload is making you lose `0.3125$` per hour.
