<?php

/**
 * Copyright © OXID eSales AG. All rights reserved.
 * See LICENSE file for license details.
 */

declare(strict_types=1);

namespace PhpDA\Writer\Strategy;

use Fhaculty\Graph\Graph;
use PhpDA\Writer\Extractor\ExtractionInterface;
use PhpDA\Writer\Extractor\Graph as GraphExtractor;

class PackageLevel2DependencyReporter extends ReportPrinter
{
    public $outputFile = './dependencies_PACKAGE_LVL_2.txt';
    public $dependencyCyclesMessage = "*Detected %d cycle(s) in FRAMEWORK/MODULE!*\n\n";
}
