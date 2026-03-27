#!/usr/bin/env -S lune run

--[[

Lint

Runs luau-lsp analyze to report type errors and deprecation warnings.

[Usage] ./Scripts/Lint.luau

--]]

local process = require("@lune/process")

local function lint()
    local sourcemapResult = process.exec("rojo", {
        "sourcemap",
        "dev.project.json",
        "-o",
        "sourcemap.json",
    })

    if not sourcemapResult.ok then
        print("Failed to generate sourcemap")
        print(sourcemapResult.stderr)
        process.exit(1)
    end

    local result = process.exec("luau-lsp", {
        "analyze",
        "--platform=lune",
        "--sourcemap=sourcemap.json",
        "--no-flags-enabled",
        "--ignore=DevPackages/**",
        "--ignore=Packages/**",
        "--ignore=Submodules/**",
        ".",
    })

    if result.stdout ~= "" then
        print(result.stdout)
    end
    if result.stderr ~= "" then
        print(result.stderr)
    end

    if result.ok then
        print("No lint errors found.")
    else
        process.exit(1)
    end
end

lint()
