# Troubleshooting (under preparation)

This page covers common error messages, what they mean, and how to resolve them.


## AttributeError

``` { .yaml .no-copy }
AttributeError: 'ConstantVariable' object has no attribute 'apply_today'
```

**Explanation**:

This error occurs when `Indication` or `Indications` elements are misconfigured.

**Possible solutions**:

- Check any `Indication` or `Indications` elements which are choice distributions. All their child elements must have probability attributes associated with them.

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

## HDFview error
In rare cases, opening "AppliedAreas" generated from a large amount of input data may cause HDFView to crash due to its data type. Use *xCP_write_csv.ipynb* to write the data to a csv.

## KeyError

``` { .yaml .no-copy }
appl_window = self._applicationWindow.get((day, field), ("time/day, space/base_geometry"))
  File "C:\xCropProtection\model\core\components\xCropProtection\distributions.py", line 264, in get
    return self._value[conv_index]
KeyError: (730121,)
```

**Explanation**:

An `ApplicationWindow` has a `scales` value of "time/day" or "time/year".

**Possible solutions**:

- Determine which `ApplicationWindow` element has a `scales` value of "time/day" or "time/year". Set `scales` to "global" (including quotation marks).

## ValueError: chunk shape

``` { .yaml .no-copy }
ValueError: Chunk shape must not be greater than data shape in any dimension. (1,) is not compatible with (0,)
```

**Explanation**:

The number of applied areas calculated by xCropProtection is different than the expected value. Incorrect or overly restrictive constraints on dates, fields, or crop type may result in zero applications being performed during the simulation.

**Possible solutions**:

- Check the value of `SimulationStart` and `SimulationEnd` in *template.xrun*. Compare these values to the `TemporalValidity` defined in all PPMCalendars used in the xCropProtection run. The `TemporalValidity` should overlap with the simulation start and end values.
- In all PPMCalendars, check `Application` elements' `ApplicationWindow` date ranges. It is possible that application windows are defined for days/months outside the simulation start and end values set in *template.xrun*.
- In all PPMCalendars, check the value of `TargetCrops`. Verify that this is an integer value and that one or more fields in the scenario have this crop type. In *\xCropProtection\scenario\\[scenario name]\geo\package.xinfo*, verify that `feature_type_attribute` refers to the correct field name. In the same file, verify that `base_landscape_geometries` refers to the correct shapefile.
- In all PPMCalendars, check the value of `TargetFields`. Verify that this is an integer value or list of integers and that one or more fields in the scenario have this ID. In *\xCropProtection\scenario\\[scenario name]\geo\package.xinfo*, verify that `feature_id_attribute` refers to the correct field name. In the same file, verify that `base_landscape_geometries` refers to the correct shapefile.

## ValueError: empty range

``` { .yaml .no-copy }
ValueError: empty range for randrange() (359, 6, -353)
```

**Explanation**:

The dates of an `ApplicationWindow` are outside of the allowable range.

**Possible solutions**:

- xCropProtection does not support `ApplicationWindow` ranges that span between multiple years (e.g. December to January).
- Check the value of all `ApplicationWindow` elements to be sure that the month that comes first in the year is listed first in the date range. For example, a window of 10-14 to 05-21 would produce this error because xCropProtection interprets this window as October 14th to May 21st, which is invalid.
- Check that the format of `ApplicationWindow` date ranges are in the format mm-dd to mm-dd.

## ValueError: probability sum

``` { .yaml .no-copy }
ValueError: Probability sum is not 1.0!
```

**Explanation**:

The sum of probability values in one of the choice distributions defined in a PPMCalendar does not equal 1.0.

**Possible solutions**:

- Check the probability values in all PPMCalendars to ensure they sum to 1.0.
- xCropProtection allows a small amount of error when calculating the sum of a choice distribution's probability values. The sum is rounded to 5 decimal places to prevent floating-point arithmetic errors that may occur when adding floating-point values in python. Further explanation can be found on the [Python.org website](https://docs.python.org/3/tutorial/floatingpoint.html).