param (
  [switch]$skip_docker = $true
)

# Check the installation by displaying the psql version
$psqlVersion = Get-Command -Name psql -ErrorAction SilentlyContinue
if ($psqlVersion) {
    $psqlVersion
} else {
    Write-Host "psql not found. PostgreSQL may not be installed correctly."
}

# Check if sqlx-cli is already installed
$installedSqlxCli = Test-Path "$env:USERPROFILE\.cargo\bin\sqlx.exe"

if ($installedSqlxCli) {
    Write-Host "sqlx-cli is already installed."
} else {
    Write-Host "sqlx-cli is not installed. Installing it now..."

    # Install sqlx-cli using cargo
    Set-Location $env:USERPROFILE
    cargo install sqlx-cli --no-default-features --features rustls,postgres

    # Check if the installation was successful
    $installedSqlxCli = Test-Path "$env:USERPROFILE\.cargo\bin\sqlx"

    if ($installedSqlxCli) {
        Write-Host "sqlx-cli has been successfully installed."
    } else {
        Write-Host "Failed to install sqlx-cli. Please make sure you have Rust and cargo installed."
    }
}

# Define some variables for the PostgreSQL Docker container
$containerName = "project_postgres_2"  # Choose a name for your container
$pgUsername = "postgres"  # Replace with your desired username
$pgPassword = "password"  # Replace with your desired password
$pgDatabase = "newsletter"  # Replace with your desired database name

if (-Not $skip_docker)
{
  # Run the PostgreSQL Docker container
  docker run --name $containerName -e POSTGRES_USER=$pgUsername -e POSTGRES_PASSWORD=$pgPassword -e POSTGRES_DB=$pgDatabase -p 5432:5432 -d postgres
}

$databaseUrl = "postgres://postgres:password@localhost:5432/newsletter"
sqlx database create --database-url $databaseUrl
sqlx migrate run --database-url $databaseUrl

Write-Host "Postgres has been migrated, ready to go!"
