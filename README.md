# UpCom SDK

A thoroughly commented template for a custom [UpDroid Commander] Tab.

## General Information

The SDK is itself a Dart package and a starting point for writing a custom Tab for [UpDroid Commander]. It is not meant to be an exhaustive source of all UpCom development-related information - other tabs can be used as implementation examples, and the UpDroid API comes with its own documentation. Therefore, the UpCom SDK includes the core components, package structure/layout, and tools that can be modified and filled in to create custom behavior.

## Usage

Clone this repo with a new name based on your application.

```shell

git clone https://bitbucket.org/updroid/upcom-sdk.git upcom-yourtab

```

Start with a fresh commit history.

```shell

rm -f .git

```

Check in all the original SDK files as a starting point.

```shell

git add .

git commit -m "file check-in"

```

Implement your own tab by replacing all the placeholders (Your Tab, upcom-yourtab, etc.) with your own names and code. An exhaustive checklist of things to change.

## Known Issues

N/A

### TODO:

- Add a starting point for an UpCom Panel.
- Add a packaging script for Tab deployment.
- Add a starting point for a [ROS] package that links to the Tab back-end.
- Add more documentation for the different parts of the package.
- Add an exhaustive checklist for things to change in the SDK as part of the implementation.

[UpDroid Commander]: http://updroid.com/upcom/
[ROS]: http://www.ros.org/