#!/bin/sh -f

if [[ $# -ne 1 ]]; then
    echo Usage: publish.sh .NET-RID
    exit 1
fi

PROJECT_FILE=Renumber/Renumber.csproj
PUBLISH_FOLDER=published/$1
MY_APPS_BASE_FOLDER=$(~/Scripts/get-my-apps-folder.sh)
MY_APPS_FOLDER=$MY_APPS_BASE_FOLDER/RC2014/Renumber

echo ""
echo "Target OS      : $1"
echo "Project        : $PROJECT_FILE"
echo "Publish Folder : $PUBLISH_FOLDER"
echo "Target Folder  : $MY_APPS_FOLDER"
echo ""

echo Publishing to $PUBLISH_FOLDER ...
rm -fr $PUBLISH_FOLDER
dotnet publish $PROJECT_FILE -c Release -r $1 --self-contained -o $PUBLISH_FOLDER

RID=$(~/Scripts/get-dotnet-rid.sh)
if [ $1 != $RID ] ; then
    exit 0
fi

echo Copying to $MY_APPS_FOLDER ...
rm -fr $MY_APPS_FOLDER
cp -r $PUBLISH_FOLDER $MY_APPS_FOLDER
