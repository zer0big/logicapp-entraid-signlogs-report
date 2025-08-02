# 1. 기본 정보 설정
RG_NAME="logicapp-rg"
LOCATION="koreacentral"
LA_NAME="entra-signin-report-la"

# 2. Log Analytics 작업 영역 정보 설정
WORKSPACE_RG="logicapp-rg"
WORKSPACE_NAME="entraid-logicapps-law"

# 3. 이메일 정보 설정
RECIPIENT_EMAIL="zerobig.kim@gmail.com"

# 4. 구독 ID 자동 설정
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# 5. logic 확장(Extension) 설치
az extension add --name logic

# 6. 리소스 그룹 생성
az group create --name $RG_NAME --location $LOCATION

# 7. Log Analytics 작업 영역 생성
az monitor log-analytics workspace create \
  --resource-group $RG_NAME \
  --workspace-name $WORKSPACE_NAME \
  --location $LOCATION

# 8. parameters.json 생성 작업
# 8.1 Log Analytics 작업 영역의 전체 리소스 ID와 고유 ID(GUID)를 조회하여 변수에 저장
WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show --resource-group $WORKSPACE_RG --workspace-name $WORKSPACE_NAME --query id -o tsv)
WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group $WORKSPACE_RG --workspace-name $WORKSPACE_NAME --query customerId -o tsv)

# 8.2 'Log Analytics Reader' 역할의 전체 리소스 ID를 조회하여 변수에 저장
ROLE_ID=$(az role definition list --name "Log Analytics Reader" --query "[0].id" -o tsv)

# 8.3 parameters.json 파일 생성
cat <<EOF > parameters.json
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "logicAppName": { "value": "$LA_NAME" },
    "location": { "value": "$LOCATION" },
    "workspaceId": { "value": "$WORKSPACE_ID" },
    "workspaceResourceId": { "value": "$WORKSPACE_RESOURCE_ID" },
    "recipientEmail": { "value": "$RECIPIENT_EMAIL" },
    "logAnalyticsReaderRoleDefinitionId": { "value": "$ROLE_ID" }
  }
}
EOF
