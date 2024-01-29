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

class ClassDependencyReporter extends ReportPrinter
{
    public $outputFile = './dependencies_CLASS.txt';
    public $dependencyCyclesMessage = "*Detected %d cycle(s) on CLASS level!*\n\n";
    private $namespaceHierarchy = [
        'Mapper',
        'Dao',
        'Service',
        'Facade',
        'Bridge',
    ];
    private $noHierarchyViolationsMessage = "*Detected 0 hierarchy violation(s)!*";
    private $hierarchyViolationsMessage = "*Hierarchy violation detected!*\nFrom: %s\nTo: %s\n\n";


    public function formatDependenciesReport(array $output): string
    {
        return $this->getCyclesReport($output)
            . $this->getHierarchyReport($output);
    }

    private function getHierarchyReport($data): string
    {
        if (!isset($data['edges'])) {
            throw new UnexpectedValueException("No Edges Data present!");
        }
        return $this->getHierarchyViolationsMessage($this->filterForEdgeDataViolations($data['edges']));
    }

    private function getHierarchyViolationsMessage(array $violations): string
    {
        if (empty($violations)) {
            return $this->noHierarchyViolationsMessage;
        }
        $txt = '';
        foreach ($violations as $violation) {
            $txt .= sprintf($this->hierarchyViolationsMessage, $violation['from'], $violation['to']);
        }
        return $txt;
    }

    private function filterForEdgeDataViolations(array $edges): array
    {
        $violations = [];
        foreach ($edges as $edge) {
            if ($this->isEdgeHierarchyViolationDetected($edge['from'], $edge['to'])) {
                $violations[] = $edge;
            }
        }
        return $violations;
    }

    private function isEdgeHierarchyViolationDetected(string $from, string $to): bool
    {
        try {
            $fromHierarchy = $this->getHierarchyLevel($from);
            $toHierarchy = $this->getHierarchyLevel($to);
        } catch (UnexpectedValueException $ex) {
            return false;
        }
        return $fromHierarchy < $toHierarchy;
    }

    private function getHierarchyLevel(string $classPath): int
    {
        foreach ($this->namespaceHierarchy as $hierarchyLevel => $namespace) {
            if (\strpos($classPath, "\\\\$namespace\\\\") !== false) {
                return $hierarchyLevel;
            }
        }
        throw new UnexpectedValueException("Class path '$classPath' doesn't contain expected hierarchy namespaces.");
    }
}
