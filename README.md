# Práctica DevOps 00 — Publicación web en AWS S3 con IA + MCP

Web estática sobre Terraform, AWS S3, Gemini CLI y Model Context Protocol (MCP).

## Componentes

- **Aplicación:** `index.html` y `style.css`.
- **Infraestructura:** `main.tf`, `variables.tf` y `outputs.tf` declaran el hosting estático de S3, la política de lectura y la publicación de `index.html`, `style.css` y `js/app.js`.
- **IA:** Gemini CLI (`gemini`). Se ha usado desde la carpeta del proyecto para revisar y desarrollar los archivos.
- **MCP:** servidor `@modelcontextprotocol/server-filesystem`, configurado en `.gemini/settings.json`. Permite a Gemini leer y trabajar con los archivos del proyecto mediante herramientas, no solo mediante una conversación.

## Despliegue

> Nunca guardes credenciales en archivos del proyecto ni las subas a Git.

1. Renueva las credenciales temporales de AWS Academy y configúralas solo en tu equipo. Comprueba la sesión:

   ```bash
   aws sts get-caller-identity
   ```

2. Consulta el bucket creado en la práctica previa y copia su nombre:

   ```bash
   aws s3api list-buckets --query 'Buckets[].Name' --output table
   ```

3. Crea la configuración local, sin versionarla:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Edita `terraform.tfvars` e indica el nombre real del bucket y su región.

4. Inicializa Terraform. Si el bucket ya existía, impórtalo antes de aplicar;
   si el laboratorio no tenía ninguno, Terraform lo creará y publicará la web de forma declarativa:

   ```bash
   terraform init
   # Solo si el bucket ya existía:
   terraform import aws_s3_bucket.site NOMBRE_DEL_BUCKET
   terraform validate
   terraform plan
   terraform apply
   ```

5. Copia la URL mostrada por `terraform output website_url` y ábrela en el navegador. Terraform sincroniza los archivos web definidos en `local.website_files` en cada aplicación. Si AWS Academy prohíbe la política pública, guarda el error como evidencia y consulta al docente qué alternativa permite el laboratorio.

### Limitación de AWS Academy

Algunos laboratorios aplican una *Service Control Policy* que deniega
`s3:GetBucketObjectLockConfiguration`. En ese caso Terraform no puede importar
un bucket preexistente, aunque el rol sí permita configurar y publicar el sitio.
Usa el despliegue equivalente incluido en el proyecto:

```bash
BUCKET_NAME="tu-bucket" AWS_REGION="us-west-2" bash deploy.sh
```

El script configura el hosting y el acceso público y publica HTML, CSS y JS.

## Verificación de MCP

Desde esta carpeta ejecuta:

```bash
gemini mcp list
gemini
```

El primer comando debe mostrar `filesystem`. En Gemini, pide al agente que lea `index.html` o que proponga una mejora en `style.css`; eso demuestra que usa el servidor MCP para operar sobre el proyecto.

## Dificultades encontradas

- Las credenciales de AWS Academy son temporales y deben renovarse al caducar.
- Un bucket ya existente debe importarse antes de que Terraform pueda administrarlo desde esta carpeta. Si no existe, Terraform lo crea desde `main.tf`.
- El endpoint de sitio web de S3 usa HTTP. Para HTTPS se requeriría una capa adicional, por ejemplo CloudFront, fuera del alcance mínimo de la práctica.

## URL final

Ejecuta `terraform output -raw website_url` después del despliegue para obtener la URL pública.
