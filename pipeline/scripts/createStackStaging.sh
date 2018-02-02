pwd=$(pwd)
# repo name which code pipeline will be setup for. Also serves as app name.
repo="api-spec"
# branch name that code pipeline will be setup for.
branch="staging"
# Environment e.g.: develop, prod, uat, staging, test
environment="staging"
# File in S3 bucket which has input values to the satck
stackParamFile="stackParams.json"
# AWS account type, dev or prod
awsAccountType="dev"
# A bucket to where stack templates will upload
pipelineBucket=elevate-pipeline-$awsAccountType
# A bucket where developer must store stackParam.json file and param.json file.
paramBucket=elevate-ms-params-$awsAccountType
# A shared bucket used for code build and artifacts
cbBucket=elevate-pipeline-codebuild-$awsAccountType
# Param files served as input to template (params for lambda, ...)
stagingFile="params.json"
aws s3 cp "$pwd/../pipeline-roles.yaml" s3://$pipelineBucket/$repo/$environment/pipeline-roles.yaml
aws s3 cp "$pwd/../pipeline.yaml" s3://$pipelineBucket/$repo/$environment/pipeline.yaml
aws s3 cp s3://$paramBucket/$repo/$environment/$stackParamFile "$pwd/$stackParamFile"
sed -i "" "s/{AppName}/$repo/g" "$pwd/$stackParamFile"
sed -i "" "s/{Environment}/$environment/g" "$pwd/$stackParamFile"
sed -i "" "s/{RepoName}/$repo/g" "$pwd/$stackParamFile"
sed -i "" "s/{Branch}/$branch/g" "$pwd/$stackParamFile"
sed -i "" "s/{PipelineBucket}/$pipelineBucket/g" "$pwd/$stackParamFile"
sed -i "" "s/{CodeBuildBucket}/$cbBucket/g" "$pwd/$stackParamFile"
sed -i "" "s/{ParamBucket}/$paramBucket/g" "$pwd/$stackParamFile"
sed -i "" "s/{StagingFile}/$stagingFile/g" "$pwd/$stackParamFile"
aws cloudformation create-stack --stack-name $repo-stack-$environment --capabilities CAPABILITY_NAMED_IAM --template-body "file://$pwd/../main.yaml" --parameters "file://$pwd/$stackParamFile"
rm "$pwd/$stackParamFile"