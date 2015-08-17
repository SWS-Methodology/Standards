---
title: Food Balance Sheets
...

Wheat
-----

For this example, we'll first consider the full process for creating a
food balance sheet for wheat. We start off with an empty table:

  Name                Production   Imports   Exports   StockChange   Food   Food Processing   Feed   Waste   Seed   Industrial   Tourist
  ------------------- ------------ --------- --------- ------------- ------ ----------------- ------ ------- ------ ------------ ---------
  Wheat               0            0         0         0             0      0                 0      0       0      0            0
  Wheat flour         0            0         0         0             0      0                 0      0       0      0            0
  Bulgur              0            0         0         0             0      0                 0      0       0      0            0
  Breakfast cereals   0            0         0         0             0      0                 0      0       0      0            0
  Wheat starch        0            0         0         0             0      0                 0      0       0      0            0
  Wheat bran          0            0         0         0             0      0                 0      0       0      0            0

### Production

For production data, we first fill in the table with any available
official figures. To impute production, we must also consider yield and
area harvested data as yield is defined as production divided by area
harvested (and thus with any two elements the third is uniquely
defined). Suppose we have the following official data:

  Name          Area Harvested   Yield   Production
  ------------- ---------------- ------- ------------
  Wheat         18500000         0       0
  Wheat flour   NA               NA      18650000

In this case, the production value is only known for wheat flour (it is
missing for wheat), and for wheat we are also missing the yield value.
The first step in the imputation process is to impute the yield, using
the previously described production imputation methodology.

![](media/rId23.png)

The final imputed value for yield in 2011 is 2.94 which seems reasonable
given the historical time series. Some models fit the data fairly well
(such as the logistic regression, spline, and loess regression). Some of
these models do not produce good forecasts (in particular, the forecast
for the loess model is quite low) but by averaging together
well-performing models, we get a good final estimate for the yield.

  Name          Area Harvested   Yield    Production
  ------------- ---------------- -------- ------------
  Wheat         18500000         2.9422   0
  Wheat flour   NA               NA       18650000

Now, we have enough information to compute the production data:

  Name          Area Harvested   Yield    Production
  ------------- ---------------- -------- ------------
  Wheat         18500000         2.9422   54420000
  Wheat flour   NA               NA       18650000

Next, we fill in the table with our production values. Production is
only imputed for primary products (and occassionally official figures
are provided for processed products, as is the case here). So, in this
case, no additional values are filled in outside of wheat and flour.

  Name                Production     Imports   Exports   StockChange   Food   Food Processing   Feed   Waste   Seed   Industrial   Tourist
  ------------------- -------------- --------- --------- ------------- ------ ----------------- ------ ------- ------ ------------ ---------
  Wheat               **54420000**   0         0         0             0      0                 0      0       0      0            0
  Wheat flour         **18650000**   0         0         0             0      0                 0      0       0      0            0
  Bulgur              **-**          0         0         0             0      0                 0      0       0      0            0
  Breakfast cereals   **-**          0         0         0             0      0                 0      0       0      0            0
  Wheat starch        **-**          0         0         0             0      0                 0      0       0      0            0
  Wheat bran          **-**          0         0         0             0      0                 0      0       0      0            0

### Trade

For this example, we take the country totals of all imports and exports
and insert into this table.

  Name                Production   Imports       Exports        StockChange   Food   Food Processing   Feed   Waste   Seed   Industrial   Tourist
  ------------------- ------------ ------------- -------------- ------------- ------ ----------------- ------ ------- ------ ------------ ---------
  Wheat               54420000     **1999100**   **32790000**   0             0      0                 0      0       0      0            0
  Wheat flour         18650000     **341500**    **572800**     0             0      0                 0      0       0      0            0
  Bulgur              -            **182500**    **580000**     0             0      0                 0      0       0      0            0
  Breakfast cereals   -            **312500**    **217300**     0             0      0                 0      0       0      0            0
  Wheat starch        -            **624900**    **224500**     0             0      0                 0      0       0      0            0
  Wheat bran          -            **258900**    **2343700**    0             0      0                 0      0       0      0            0

### Stock Changes

We now estimate the stock changes. Note that for most products, we
assume that countries do not hold stocks. Generally, stocks will only be
held for primary level products, and not even all of these products. The
numbers below represent the estimated stock changes (by the stock
imputation methodology described previously) for the example country
we're considering.

  Name                Production   Imports   Exports    StockChange   Food   Food Processing   Feed   Waste   Seed   Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ------ ----------------- ------ ------- ------ ------------ ---------
  Wheat               54420000     1999100   32790000   **-230600**   0      0                 0      0       0      0            0
  Wheat flour         18650000     341500    572800     **-**         0      0                 0      0       0      0            0
  Bulgur              -            182500    580000     **-**         0      0                 0      0       0      0            0
  Breakfast cereals   -            312500    217300     **-**         0      0                 0      0       0      0            0
  Wheat starch        -            624900    224500     **-**         0      0                 0      0       0      0            0
  Wheat bran          -            258900    2343700    **-**         0      0                 0      0       0      0            0

### Food

The allocation to food, on the other hand, can potentially be considered
at any processing level, although some commodities (such as wheat) are
assumed to not be eaten as such. We impute food consumption numbers for
the example country and update the SUA table below.

  Name                Production   Imports   Exports    StockChange   Food           Food Processing   Feed   Waste   Seed   Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- -------------- ----------------- ------ ------- ------ ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       **-**          0                 0      0       0      0            0
  Wheat flour         18650000     341500    572800     -             **18540000**   0                 0      0       0      0            0
  Bulgur              -            182500    580000     -             **3700**       0                 0      0       0      0            0
  Breakfast cereals   -            312500    217300     -             **98100**      0                 0      0       0      0            0
  Wheat starch        -            624900    224500     -             **-**          0                 0      0       0      0            0
  Wheat bran          -            258900    2343700    -             **-**          0                 0      0       0      0            0

### Feed

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed          Waste   Seed   Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- ------------- ------- ------ ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          0                 **4898000**   0       0      0            0
  Wheat flour         18650000     341500    572800     -             18540000   0                 **-**         0       0      0            0
  Bulgur              -            182500    580000     -             3700       0                 **-**         0       0      0            0
  Breakfast cereals   -            312500    217300     -             98100      0                 **-**         0       0      0            0
  Wheat starch        -            624900    224500     -             -          0                 **-**         0       0      0            0
  Wheat bran          -            258900    2343700    -             -          0                 **3355500**   0       0      0            0

### Losses

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste        Seed   Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- ------------ ------ ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          0                 4898000   **560300**   0      0            0
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         **-**        0      0            0
  Bulgur              -            182500    580000     -             3700       0                 -         **-**        0      0            0
  Breakfast cereals   -            312500    217300     -             98100      0                 -         **-**        0      0            0
  Wheat starch        -            624900    224500     -             -          0                 -         **-**        0      0            0
  Wheat bran          -            258900    2343700    -             -          0                 3355500   **-**        0      0            0

### Seed

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed          Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- ------------- ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          0                 4898000   560300   **1904200**   0            0
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         -        **-**         0            0
  Bulgur              -            182500    580000     -             3700       0                 -         -        **-**         0            0
  Breakfast cereals   -            312500    217300     -             98100      0                 -         -        **-**         0            0
  Wheat starch        -            624900    224500     -             -          0                 -         -        **-**         0            0
  Wheat bran          -            258900    2343700    -             -          0                 3355500   -        **-**         0            0

### Industrial Utilization

For most commodities, industrial utilization will be zero. This element
can be important when considering commodities related to biofuels and
vegetable oils, but for wheat it is irrelevant.

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          0                 4898000   560300   1904200   **-**        0
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         -        -         **-**        0
  Bulgur              -            182500    580000     -             3700       0                 -         -        -         **-**        0
  Breakfast cereals   -            312500    217300     -             98100      0                 -         -        -         **-**        0
  Wheat starch        -            624900    224500     -             -          0                 -         -        -         **-**        0
  Wheat bran          -            258900    2343700    -             -          0                 3355500   -        -         **-**        0

### Tourist Consumption

The tourist consumption estimation approach uses tourist data from the
WTO as well as last year's consumption patterns to estimate the impact
of tourism on local consumption. Note that tourist consumption can be
negative; as an extreme example consider a case where many nationals
travel abroad but no tourists enter. In this case, the country will have
a negative \`\`tourist consumption'' because more calories will be
consumed abroad than locally.

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ------------
  Wheat               54420000     1999100   32790000   -230600       -          0                 4898000   560300   1904200   -            **65**
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         -        -         -            **-29200**
  Bulgur              -            182500    580000     -             3700       0                 -         -        -         -            **-**
  Breakfast cereals   -            312500    217300     -             98100      0                 -         -        -         -            **-**
  Wheat starch        -            624900    224500     -             -          0                 -         -        -         -            **-**
  Wheat bran          -            258900    2343700    -             -          0                 3355500   -        -         -            **-**

### Standardization and Balancing

Now, suppose we have the following commodity tree:

![](media/rId33.png)

We first start with the pre-standardized table:

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          0                 4898000   560300   1904200   -            65
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         -        -         -            -29200
  Bulgur              -            182500    580000     -             3700       0                 -         -        -         -            -
  Breakfast cereals   -            312500    217300     -             98100      0                 -         -        -         -            -
  Wheat starch        -            624900    224500     -             -          0                 -         -        -         -            -
  Wheat bran          -            258900    2343700    -             -          0                 3355500   -        -         -            -

We then compute the required \`\`production'' of each of the processed
products to satisfy any deficits due to exports or consumption (note
that we can allow production to be zero if supply exceeds utilization).

  Name                Production    Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------- --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ---------
  Wheat               54420000      1999100   32790000   -230600       -          0                 4898000   560300   1904200   -            65
  Wheat flour         18650000      341500    572800     -             18540000   0                 -         -        -         -            -29200
  Bulgur              **401200**    182500    580000     -             3700       0                 -         -        -         -            -
  Breakfast cereals   **2900**      312500    217300     -             98100      0                 -         -        -         -            -
  Wheat starch        **0**         624900    224500     -             -          0                 -         -        -         -            -
  Wheat bran          **5440300**   258900    2343700    -             -          0                 3355500   -        -         -            -

Since wheat starch is produced from wheat flour, we would first need to
ensure the wheat flour "food to processing" can cover any deficits of
wheat starch. However, since wheat starch imports exceed exports plus
food, we don't have to worry about this requirement. Instead, we can
just standardize all the first processed level products back to food to
processing of wheat.

  Name                Production (processed)   SD(Production)   Wheat Equivalent   SD(Wheat Equivalent)
  ------------------- ------------------------ ---------------- ------------------ ----------------------
  Wheat flour         18650000                 0                25910000           0
  Bulgur              401200                   880              422300             930
  Breakfast cereals   2900                     1500             2900               1500
  Wheat bran          5440300                  167800           24730000           762600

Now, we wish to compute the distribution for the "food to processing"
element for wheat. The main requirement is in the wheat flour and bran,
and it should be noted that the 26 million kilogram requirement for
wheat flour will automatically be satisfied if the 35 million kilogram
requirement for wheat bran is satisfied (as they are produced together).
Thus, the food to processing element for wheat has a mean of 35 million
kilograms (the sum of the last three) and a standard deviation of 2.55
million kilograms (the square-root of the sum of the squares of the last
three standard deviations). Thus, we now have the following table:

  Name                Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ---------
  Wheat               54420000     1999100   32790000   -230600       -          **26330000**      4898000   560300   1904200   -            65
  Wheat flour         18650000     341500    572800     -             18540000   0                 -         -        -         -            -29200
  Bulgur              401200       182500    580000     -             3700       0                 -         -        -         -            -
  Breakfast cereals   2900         312500    217300     -             98100      0                 -         -        -         -            -
  Wheat starch        0            624900    224500     -             -          0                 -         -        -         -            -
  Wheat bran          5440300      258900    2343700    -             -          0                 3355500   -        -         -            -

Now, we must balance this table. To do this, we need to extract the
computed standard deviations of each element. The table below shows the
expected value and estimated standard deviation for each of the elements
for wheat:

  Variable        Production   Imports   Exports    StockChange   Food   Food Processing   Feed      Waste    Seed      Industrial   Tourist
  --------------- ------------ --------- ---------- ------------- ------ ----------------- --------- -------- --------- ------------ ---------
  Mean            54420000     1999100   32790000   -230600       0      26330000          4898000   560300   1904200   0            65
  Standard Dev.   544188       0         0          89854         NA     1749              244900    56031    1129      NA           7

Note that in this case, the standard deviation for food for processing
is very small because the flour production is an official figure (and
this is the main use of wheat). Thus, the "food for processing" element
is not adjusted much.

  Variable        Production   Imports   Exports    StockChange   Food   Food Processing   Feed      Waste    Seed      Industrial   Tourist
  --------------- ------------ --------- ---------- ------------- ------ ----------------- --------- -------- --------- ------------ ---------
  Mean            62350000     1999100   32790000   -446800       0      26330000          3292200   476300   1904200   0            65
  Standard Dev.   544188       0         0          89854         NA     1749              244900    56031    1129      NA           7

Now, when balancing, we find that food for processing is adjusted down
slightly. This adjustment to food of wheat implies that the production
of children commodities must also be updated (and hence their food
values as well).

  Name                Production (processed)   SD(Production)   Wheat Equivalent   SD(Wheat Equivalent)   Adjustment
  ------------------- ------------------------ ---------------- ------------------ ---------------------- ------------
  Wheat flour         18650000                 0                25910000           0                      0
  Bulgur              401200                   880              422300             930                    0
  Breakfast cereals   2900                     1500             2900               1500                   0
  Wheat bran          5440300                  167800           24730000           762600                 -80

We can now update the production numbers for each of the first level
primary elements. Note that in the process of creating flour, we also
create bran and germ. The amount of bran and germ created, in this case,
is determined by the amount of flour we need to create (as that was our
most stringent requirement). Thus, we have:

  Name                Production    Imports   Exports    StockChange   Food        Food Processing   Feed          Waste    Seed      Industrial   Tourist
  ------------------- ------------- --------- ---------- ------------- ----------- ----------------- ------------- -------- --------- ------------ ---------
  Wheat               62350000      1999100   32790000   -446800       0           26330000          3292200       476300   1904200   0            65
  Wheat flour         18650000      341500    572800     -             18540000    0                 -             -        -         -            -29200
  Wheat germ          **1554300**   **0**     **0**      **0**         **0**       **0**             **1554300**   **0**    **0**     **0**        **0**
  Bulgur              **401200**    182500    580000     0             **3700**    0                 0             0        0         0            0
  Breakfast cereals   **3000**      312500    217300     0             **98200**   0                 0             0        0         0            0
  Wheat starch        0             624900    224500     -             -           0                 -             -        -         -            -
  Wheat bran          **5699300**   258900    2343700    0             0           0                 **3614500**   0        0         0            0

Our food balance sheet is nearly completed, except that some commodities
haven't been handled yet. In particular, wheat starch had imports
exceeding exports and so we have not balanced that commodity yet; also,
wheat flour has official production and so we haven't modified that
commodity either. These unbalanced elements must be updated, and since
the production is already fixed (either because it's an official figure
or because it's 0) the balancing is very straight-forward: the
uncertainty will be entirely allocated to food (or, in general, to
either food or feed).

  Name                Production   Imports   Exports    StockChange   Food           Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------------------- ------------ --------- ---------- ------------- -------------- ----------------- --------- -------- --------- ------------ ---------
  Wheat               62350000     1999100   32790000   -446800       0              26330000          3292200   476300   1904200   0            65
  Wheat flour         18650000     341500    572800     -             **18450000**   0                 -         -        -         -            -29200
  Wheat germ          1554300      0         0          0             0              0                 1554300   0        0         0            0
  Bulgur              401200       182500    580000     0             3700           0                 0         0        0         0            0
  Breakfast cereals   3000         312500    217300     0             98200          0                 0         0        0         0            0
  Wheat starch        0            624900    224500     -             **-**          0                 -         -        -         -            -
  Wheat bran          5699300      258900    2343700    0             0              0                 3614500   0        0         0            0

Now, the final step is aggregating this full table back into primary
equivalent. For most elements, this is trivial: for example, the final
stock change for wheat will simply be the current stock change because
there is no stock change for processed products. However, there are
three elements that must be handled differently: imports, exports, and
food. Note that the final value for wheat equivalent production is
simply the current value for wheat production: this is because
\`\`production'' of flour (or any other processed product) isn't really
production in the sense that the flour is acquired from a different
commodity (whereas production of wheat is truly a production as it is
not derived from anything else). Also, food processing will not be
standardized as it is more of an accounting variable that specifies how
much of a commodity at one level should be processed into a different
commodity.

To standardize trade and food, we can simply aggregate the trade and
food of the children commodities up into their primary equivalent by
dividing by the extraction rate. We add these primary equivalents to the
current value of trade/food of wheat, and we have our final, primary
equivalent trade/food of wheat. Also, feed is not standardized back into
wheat equivalent as it is accounted for **???**.

  Name    Production   Imports   Exports    StockChange   Food       Food Processing   Feed      Waste    Seed      Industrial   Tourist
  ------- ------------ --------- ---------- ------------- ---------- ----------------- --------- -------- --------- ------------ ---------
  Wheat   62350000     3999200   34780000   -446800       25730000   26330000          3292200   476300   1904200   0            -40500

We can also compute calories, fats, and proteins at this point. First,
we apply a calorie/fat/protein content factor to each individual
element:

  Name                Quantity       Energy     Protein   Fat
  ------------------- -------------- ---------- --------- ---------
  Wheat               0.000          1420.937   12.3400   1.86500
  Wheat flour         18449983.700   1472.172   11.0475   1.33875
  Wheat germ          0.000          NA         NA        NA
  Bulgur              3706.173       NA         NA        NA
  Breakfast cereals   98189.422      NA         NA        NA
  Wheat starch        NA             NA         NA        NA
  Wheat bran          0.000          NA         NA        NA

Standardization is trivial: all the commodities here are purely
additive, so the standardized calories/fats/proteins are simply the sum
of the total calories/fats/proteins for each element:

  Energy (millions)   Protein (millions)   Fat (millions)
  ------------------- -------------------- ----------------
  27161.56            203.83               24.7
