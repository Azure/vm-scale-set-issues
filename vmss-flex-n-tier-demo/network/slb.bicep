//LB name
param slbName string = 'myLoadBalancer'


var location = resourceGroup().location
var slbPIPName = '${slbName}-PIP'

resource slbPIP 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: slbPIPName
  location: location
  sku:{
    tier: 'Regional'
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}

resource slb 'Microsoft.Network/loadBalancers@2020-07-01' = {
  name: slbName
  location: location
  tags: {}
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: slbPIP.id
          }
        }
        name: '${slbName}FrontEndConfig'
      }
    ]
    backendAddressPools: [
      {
        properties: {}
        name: 'bepool01'
      }
      {
        properties: {}
        name: 'bepool02'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/loadBalancers', slbName)}/frontendIPConfigurations/${slbName}FrontEndConfig'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers', slbName)}/backendAddressPools/bepool01'
          }
          probe: {
            id: '${resourceId('Microsoft.Network/loadBalancers', slbName)}/probes/${slbName}-probe01'
          }
          protocol: 'Tcp'
          loadDistribution: 'Default'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
          enableTcpReset: false
          disableOutboundSnat: false
        }
        name: 'string'
      }
    ]
    probes: [
      {
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
        name: '${slbName}-probe01'
      }
    ]
  }
}
output slbId  string = slb.id
output slbBackendPoolArray array = slb.properties.backendAddressPools
output slbPublicIPAddress string = slbPIP.properties.ipAddress
output slbProbe array = slb.properties.probes
