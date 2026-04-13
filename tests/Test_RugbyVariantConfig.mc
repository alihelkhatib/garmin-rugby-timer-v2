/*
Test: tests/Test_RugbyVariantConfig.mc

What this test file covers:
- Verifies built-in variant defaults and the helpers that adjust variant timings and labels.

How to run locally:
- See docs/testing.md for SDK/CLI commands. Tests run at app startup via Toybox.Test.

Key assertions/behaviours:
- Default half lengths, sin-bin durations and conversion windows for different variants (Fifteens, Sevens, Tens, U19).
- Variant override helpers produce a custom variant with adjusted timings and correct variantId.
- Fixed labels for home/away teams are present in defaults.

Preconditions / setup:
- RugbyVariantConfig.defaultSetup and helper functions are exercised; no external dependencies.
*/

using Toybox.Test;

(:test)
function testBuiltInVariantDefaults(logger) {
    var fifteens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    // FIFTEENS should use 40-minute halves
    Test.assertEqual(40 * 60, fifteens["halfLengthSeconds"]);
    // Default sin-bin length for FIFTEENS
    Test.assertEqual(10 * 60, fifteens["sinBinLengthSeconds"]);
    // Conversion window for FIFTEENS (seconds)
    Test.assertEqual(90, fifteens["conversionLengthSeconds"]);

    var sevens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_SEVENS);
    // SEVENS short halves
    Test.assertEqual(7 * 60, sevens["halfLengthSeconds"]);
    Test.assertEqual(2 * 60, sevens["sinBinLengthSeconds"]);
    Test.assertEqual(30, sevens["conversionLengthSeconds"]);

    var tens = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_TENS);
    // TENS half length
    Test.assertEqual(10 * 60, tens["halfLengthSeconds"]);

    var u19 = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_U19);
    // U19 half length
    Test.assertEqual(35 * 60, u19["halfLengthSeconds"]);
}

(:test)
function testVariantOverrides(logger) {
    var setup = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    // Adjust half minutes and sin-bin/conversion windows to custom values
    setup = RugbyVariantConfig.adjustHalfMinutes(setup, -5);
    setup = RugbyVariantConfig.withSinBinSeconds(setup, 8 * 60);
    setup = RugbyVariantConfig.withConversionSeconds(setup, 60);
    // Expect a custom variant id when overrides are applied
    Test.assertEqual(RUGBY_VARIANT_CUSTOM, setup["variantId"]);
    Test.assertEqual(35 * 60, setup["halfLengthSeconds"]);
    Test.assertEqual(8 * 60, setup["sinBinLengthSeconds"]);
    Test.assertEqual(60, setup["conversionLengthSeconds"]);
}

(:test)
function testFixedTeamLabels(logger) {
    var setup = RugbyVariantConfig.defaultSetup(RUGBY_VARIANT_FIFTEENS);
    // Default labels should be present and unchanged
    Test.assertEqual("Home", setup["homeLabel"]);
    Test.assertEqual("Away", setup["awayLabel"]);
}



