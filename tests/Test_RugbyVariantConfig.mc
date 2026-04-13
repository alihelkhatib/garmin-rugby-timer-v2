using Toybox.Test;

(:test)
function testBuiltInVariantDefaults(logger) {
    var fifteens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    Test.assertEqual(40 * 60, fifteens["halfLengthSeconds"]);
    Test.assertEqual(10 * 60, fifteens["sinBinLengthSeconds"]);
    Test.assertEqual(90, fifteens["conversionLengthSeconds"]);

    var sevens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_SEVENS);
    Test.assertEqual(7 * 60, sevens["halfLengthSeconds"]);
    Test.assertEqual(2 * 60, sevens["sinBinLengthSeconds"]);
    Test.assertEqual(30, sevens["conversionLengthSeconds"]);

    var tens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_TENS);
    Test.assertEqual(10 * 60, tens["halfLengthSeconds"]);

    var u19 = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_U19);
    Test.assertEqual(35 * 60, u19["halfLengthSeconds"]);
}

(:test)
function testVariantOverrides(logger) {
    var setup = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    setup = RugbyVariantConfig.adjustHalfMinutes(setup, -5);
    setup = RugbyVariantConfig.withSinBinSeconds(setup, 8 * 60);
    setup = RugbyVariantConfig.withConversionSeconds(setup, 60);
    Test.assertEqual(RUGBY_VARIANT_CUSTOM, setup["variantId"]);
    Test.assertEqual(35 * 60, setup["halfLengthSeconds"]);
    Test.assertEqual(8 * 60, setup["sinBinLengthSeconds"]);
    Test.assertEqual(60, setup["conversionLengthSeconds"]);
}

(:test)
function testFixedTeamLabels(logger) {
    var setup = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    Test.assertEqual("Home", setup["homeLabel"]);
    Test.assertEqual("Away", setup["awayLabel"]);
}



