# Troubleshooting - xOffFieldSoilRisk Landscape Model

This page covers common error messages, what they mean, and how to resolve them.

## FileExistsError

``` { .yaml .no-copy }
FileExistsError: [WinError 183] Cannot create a file when that file already exists:
'C:\\xCropProtection\\run\\Rummen-xCP-TestingScenario'
```

**Explanation**:

A folder with the same name as `SimID` exists in the *\...\run\\* folder.

**Possible solutions**:

- Delete or move the folder to run xCropProtection using that `SimID`.
- Change the `SimID` value to one that does not already exist in the *\...\run\\* folder.

## FileNotFoundError

``` { .yaml .no-copy}
FileNotFoundError: [Errno 2] No such file or directory: 'C:\\xCropProtection\\run\\T1EJS3N0CON7NRN3.xml'
```

**Explanation**:

No *run* folder exists in the xCropProtection directory. This usually occurs the first time the repository is cloned from GitHub.

**Possible solutions**:

- Create a new folder with the name run in the root directory of xCropProtection. This should be on the same level as the *model* and *scenario* folders.
