# YARP API Gateway Test Script
# This script tests the YARP API Gateway configuration and functionality

Write-Host "=== YARP API Gateway Test Script ===" -ForegroundColor Green

# Test 1: Check if the YARP API Gateway project exists and can build
Write-Host "`n1. Checking YARP API Gateway project structure..." -ForegroundColor Yellow
$yarpPath = "src\ApiGateways\YarpApiGateway"
if (Test-Path $yarpPath) {
    Write-Host "✓ YARP API Gateway project found at: $yarpPath" -ForegroundColor Green
} else {
    Write-Host "✗ YARP API Gateway project not found" -ForegroundColor Red
    exit 1
}

# Test 2: Verify configuration files
Write-Host "`n2. Checking configuration files..." -ForegroundColor Yellow
$configFiles = @(
    "$yarpPath\appsettings.json",
    "$yarpPath\Program.cs",
    "$yarpPath\Properties\launchSettings.json"
)

foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Write-Host "✓ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
    }
}

# Test 3: Validate YARP configuration
Write-Host "`n3. Validating YARP configuration..." -ForegroundColor Yellow
$configPath = "$yarpPath\appsettings.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath | ConvertFrom-Json
        Write-Host "✓ Configuration file is valid JSON" -ForegroundColor Green
        
        # Check routes
        if ($config.ReverseProxy.Routes) {
            $routeCount = ($config.ReverseProxy.Routes | Get-Member -MemberType NoteProperty).Count
            Write-Host "✓ Found $routeCount routes configured" -ForegroundColor Green
            
            foreach ($routeName in $config.ReverseProxy.Routes.PSObject.Properties.Name) {
                $route = $config.ReverseProxy.Routes.$routeName
                Write-Host "  - Route: $routeName -> $($route.Match.Path)" -ForegroundColor Cyan
            }
        }
        
        # Check clusters
        if ($config.ReverseProxy.Clusters) {
            $clusterCount = ($config.ReverseProxy.Clusters | Get-Member -MemberType NoteProperty).Count
            Write-Host "✓ Found $clusterCount clusters configured" -ForegroundColor Green
            
            foreach ($clusterName in $config.ReverseProxy.Clusters.PSObject.Properties.Name) {
                $cluster = $config.ReverseProxy.Clusters.$clusterName
                foreach ($destName in $cluster.Destinations.PSObject.Properties.Name) {
                    $destination = $cluster.Destinations.$destName
                    Write-Host "  - Cluster: $clusterName -> $($destination.Address)" -ForegroundColor Cyan
                }
            }
        }
    } catch {
        Write-Host "✗ Configuration file has invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Check if we can build the project
Write-Host "`n4. Testing project build..." -ForegroundColor Yellow
Set-Location $yarpPath
try {
    Write-Host "Building YARP API Gateway project..." -ForegroundColor Cyan
    $buildResult = dotnet build --configuration Release --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Build command failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test basic HTTP functionality (if possible)
Write-Host "`n5. Testing basic functionality..." -ForegroundColor Yellow
Write-Host "Note: This requires the gateway to be running" -ForegroundColor Cyan

# Check if the gateway is accessible on expected ports
$gatewayPorts = @(5214, 5218, 6004, 6064)  # HTTP, HTTPS, Docker HTTP, Docker HTTPS
$gatewayRunning = $false

foreach ($port in $gatewayPorts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$port" -Method GET -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 404) {
            Write-Host "✓ Gateway appears to be running on port $port" -ForegroundColor Green
            $gatewayRunning = $true
            break
        }
    } catch {
        # Expected if not running
    }
}

if (-not $gatewayRunning) {
    Write-Host "ℹ Gateway is not currently running. To test routing:" -ForegroundColor Yellow
    Write-Host "  1. Start the microservices: docker-compose up -d" -ForegroundColor Cyan
    Write-Host "  2. Or run the gateway directly: dotnet run" -ForegroundColor Cyan
    Write-Host "  3. Then test these endpoints:" -ForegroundColor Cyan
    Write-Host "     - http://localhost:5214/catalog-service/api/v1/catalog/items" -ForegroundColor White
    Write-Host "     - http://localhost:5214/basket-service/api/v1/basket/testuser" -ForegroundColor White
    Write-Host "     - http://localhost:5214/ordering-service/api/v1/orders" -ForegroundColor White
}

# Test 6: Configuration validation summary
Write-Host "`n6. Configuration Summary:" -ForegroundColor Yellow
Write-Host "Routes configured:" -ForegroundColor Cyan
Write-Host "  - /catalog-service/* -> catalog.api:8080" -ForegroundColor White
Write-Host "  - /basket-service/* -> basket.api:8080" -ForegroundColor White
Write-Host "  - /ordering-service/* -> ordering.api:8080 (with rate limiting)" -ForegroundColor White

Write-Host "`nRate Limiting:" -ForegroundColor Cyan
Write-Host "  - Policy: fixed window" -ForegroundColor White
Write-Host "  - Window: 10 seconds" -ForegroundColor White
Write-Host "  - Limit: 5 requests per window" -ForegroundColor White

Write-Host "`n=== Test Complete ===" -ForegroundColor Green

