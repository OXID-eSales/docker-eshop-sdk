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
use UnexpectedValueException;

class ReportPrinter extends AbstractGraphViz
{
    public $outputFile = '';
    public $dependencyCyclesMessage = '';
    private $cyclesHeaderMessage = "Cycle %d:\n";
    private $cycleClassMessage = "\t%s\n";

    private $extractor;

    public function setExtractor(ExtractionInterface $extractor): void
    {
        $this->extractor = $extractor;
    }

    public function getExtractor(): ExtractionInterface
    {
        if (!$this->extractor instanceof ExtractionInterface) {
            $this->extractor = new GraphExtractor;
        }
        return $this->extractor;
    }

    public function toString(Graph $graph)
    {
        file_put_contents(
            $this->outputFile,
            $this->formatDependenciesReport(
                $this->getExtractor()->extract($graph)
            )
        );

        return $this->getGraphViz()->setFormat('svg')->createImageData($graph);
    }

    public function formatDependenciesReport(array $output): string
    {
        file_put_contents('/app/src/debug.json', json_encode($output));
        return $this->getCyclesReport($output);
    }

    public function getCyclesReport(array $data): string
    {
        if (!isset($data['cycles'])) {
            throw new UnexpectedValueException("No Cycles Data present!");
        }
        $count = 1;
        $txt = sprintf($this->dependencyCyclesMessage, count($data['cycles']));
        foreach ($data['cycles'] as $cycle) {
            $txt .= sprintf($this->cyclesHeaderMessage, $count++);
            foreach ($cycle as $className) {
                $txt .= sprintf($this->cycleClassMessage, $className);
            }
            $txt .= "\n";
        }
        return $txt;
    }
}
