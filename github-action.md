# instruction to setup github-action

```
# Create a Service Account for Github
SERVICE_ACCOUNT_ID=github-action-sa
PROJECT_ID="your project id"
gcloud config set project $PROJECT_ID
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
 --description="Service account for Github" --display-name="$SERVICE_ACCOUNT_ID"

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/owner"

gcloud iam service-accounts keys create key-file.json \
  --iam-account=$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com


# Setup secret in Github
create a JSON key that you can download. Encode it to Base 64 (for example by using base64 -i /path/to/your/key-file.json in your terminal).
Then go to your Github repository secrets and add the base64-encoded string as a new secret named GOOGLE_APPLICATION_CREDENTIALS
```