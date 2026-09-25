targetScope = 'resourceGroup'

param location string = resourceGroup().location

output selectedLocation string = location
