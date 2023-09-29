# Define la región de AWS que deseas utilizar
provider "aws" {
  region = "us-east-1"  # Cambia esto a tu región preferida
}

# Crea un bucket de S3 para almacenar archivos estáticos
resource "aws_s3_bucket" "static_files_bucket" {
  bucket = "mi-aplicacion-static-files"  # Cambia esto a un nombre único
  acl    = "public-read"  # Esto permite el acceso público a los archivos estáticos
}

# Crea una distribución de CloudFront para distribuir contenido estático
resource "aws_cloudfront_distribution" "static_files_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_files_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Configura los registros de acceso de CloudFront
  logging_config {
    bucket         = "mi-logging-bucket"  # Cambia esto a un bucket de S3 válido
    include_cookies = false
    prefix         = "cloudfront-logs/"
  }

  # Define las restricciones de acceso si es necesario
  # (por ejemplo, restricciones de geo-bloqueo o de referente)

  # Define las configuraciones de precio si es necesario

  # Define otros ajustes de CloudFront según sea necesario
}

# Crea una función Lambda
resource "aws_lambda_function" "my_lambda_function" {
  filename      = "ruta-a-tu-archivo-zip-de-la-funcion-lambda.zip"
  function_name = "mi-funcion-lambda"  # Cambia esto a un nombre único
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"  # Cambia esto según el lenguaje que estés utilizando
}

# Crea un rol IAM para la función Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "mi-rol-iam-para-lambda"  # Cambia esto a un nombre único
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Crea una API Gateway y expone la función Lambda a través de ella
resource "aws_api_gateway_rest_api" "my_api" {
  name = "mi-api"  # Cambia esto a un nombre único
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "my-resource"  # Cambia esto a tu ruta deseada
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.my_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [aws_api_gateway_integration.my_integration]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "dev"  # Cambia esto a tu etapa deseada
}

# Exporta la URL de la API Gateway
output "api_gateway_url" {
  value = aws_api_gateway_deployment.my_deployment.invoke_url
}

# Exporta la URL de CloudFront
output "cloudfront_url" {
  value = aws_cloudfront_distribution.static_files_distribution.domain_name
}
