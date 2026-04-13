/*
 * Purpose: Provide preset variant configurations and helpers for applying user overrides.
 * Public API: RugbyVariantConfig static API: presets(), defaultSetup(variantId), applyOverrides, withSinBinSeconds, withConversionSeconds, savePreferences(), loadPreferences()
 * Key state: none (stateless static helpers)
 * Interactions: RugbyGameModel, UI variant selection; tests/Test_RugbyVariantConfig.mc
 * Example usage: RugbyVariantConfig.defaultSetup(RUGBY_DEFAULT_VARIANT)
 * TODOs/notes: Persistence is intentionally disabled (savePreferences) until app-level store is wired
 */

import Toybox.Application;
import Toybox.Lang;

const RUGBY_VARIANT_FIFTEENS = "fifteens";
const RUGBY_VARIANT_SEVENS = "sevens";
const RUGBY_VARIANT_TENS = "tens";
const RUGBY_VARIANT_U19 = "u19";
const RUGBY_VARIANT_CUSTOM = "custom";
const RUGBY_DEFAULT_VARIANT = RUGBY_VARIANT_FIFTEENS;

class RugbyVariantConfig {

    static function presets() as Dictionary {
        return {
            RUGBY_VARIANT_FIFTEENS => {
                "id" => RUGBY_VARIANT_FIFTEENS,
                "name" => "15s",
                "halfLengthSeconds" => 2400,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 600,
                "conversionLengthSeconds" => 90
            },
            RUGBY_VARIANT_SEVENS => {
                "id" => RUGBY_VARIANT_SEVENS,
                "name" => "7s",
                "halfLengthSeconds" => 420,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 120,
                "conversionLengthSeconds" => 30
            },
            RUGBY_VARIANT_TENS => {
                "id" => RUGBY_VARIANT_TENS,
                "name" => "10s",
                "halfLengthSeconds" => 600,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 300,
                "conversionLengthSeconds" => 60
            },
            RUGBY_VARIANT_U19 => {
                "id" => RUGBY_VARIANT_U19,
                "name" => "U19",
                "halfLengthSeconds" => 2100,
                "halfCount" => 2,
                "sinBinLengthSeconds" => 480,
                "conversionLengthSeconds" => 90
            } as Dictionary
        } as Dictionary;
    }

    static function defaultSetup(variantId as String) as Dictionary {
        var allPresets = presets() as Dictionary;
        var preset = allPresets[variantId] as Dictionary?;
        if (preset == null) {
            preset = allPresets[RUGBY_DEFAULT_VARIANT] as Dictionary;
        }

        return {
            "variantId" => preset["id"],
            "variantName" => preset["name"],
            "halfLengthSeconds" => preset["halfLengthSeconds"],
            "normalHalfLengthSeconds" => preset["halfLengthSeconds"],
            "halfCount" => preset["halfCount"],
            "sinBinLengthSeconds" => preset["sinBinLengthSeconds"],
            "conversionLengthSeconds" => preset["conversionLengthSeconds"],
            "homeLabel" => "Home",
            "awayLabel" => "Away"
        } as Dictionary;
    }

    static function applyOverrides(setup as Dictionary, halfDeltaMinutes as Number, sinBinSeconds as Number?, conversionSeconds as Number?) as Dictionary {
        var updated = cloneSetup(setup) as Dictionary;
        if (halfDeltaMinutes != 0) {
            var nextHalf = (updated["halfLengthSeconds"] + (halfDeltaMinutes * 60)) as Number;
            updated["halfLengthSeconds"] = clamp(nextHalf, 0, normalHalfLengthSeconds(updated));
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        if (sinBinSeconds != null) {
            updated["sinBinLengthSeconds"] = clamp(sinBinSeconds, 60, 1200);
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        if (conversionSeconds != null) {
            updated["conversionLengthSeconds"] = clamp(conversionSeconds, 15, 300);
            updated["variantId"] = RUGBY_VARIANT_CUSTOM;
            updated["variantName"] = "Custom";
        }
        return updated;
    }

    static function adjustHalfMinutes(setup as Dictionary, deltaMinutes as Number) as Dictionary {
        return applyOverrides(setup, deltaMinutes, null, null);
    }

    static function normalHalfLengthSeconds(setup as Dictionary) as Number {
        if (setup["normalHalfLengthSeconds"] != null) {
            return setup["normalHalfLengthSeconds"];
        }
        return setup["halfLengthSeconds"];
    }

    static function withSinBinSeconds(setup as Dictionary, seconds as Number) as Dictionary {
        return applyOverrides(setup, 0, seconds, null);
    }

    static function withConversionSeconds(setup as Dictionary, seconds as Number) as Dictionary {
        return applyOverrides(setup, 0, null, seconds);
    }

    static function cloneSetup(setup as Dictionary) as Dictionary {
        return {
            "variantId" => setup["variantId"],
            "variantName" => setup["variantName"],
            "halfLengthSeconds" => setup["halfLengthSeconds"],
            "normalHalfLengthSeconds" => normalHalfLengthSeconds(setup),
            "halfCount" => setup["halfCount"],
            "sinBinLengthSeconds" => setup["sinBinLengthSeconds"],
            "conversionLengthSeconds" => setup["conversionLengthSeconds"],
            "homeLabel" => setup["homeLabel"],
            "awayLabel" => setup["awayLabel"]
        } as Dictionary;
    }

    static function savePreferences(setup as Dictionary) as Void {
        // Preference persistence is intentionally disabled until the app property
        // store is wired with the correct Connect IQ API shape for this project.
    }

    static function loadPreferences() as Dictionary {
        return defaultSetup(RUGBY_DEFAULT_VARIANT);
    }

    static function clamp(value as Number, minValue as Number, maxValue as Number) as Number {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}

