<?php

namespace LoaderBundle\Exception;

use Throwable;

class UrlNotFoundException extends \Exception
{
    protected $url;

    public function __construct($url, $message = '', $code = 0, Throwable $previous = null)
    {
        $this->url = $url;

        $message = sprintf('URL "%s" could not be loaded.', $url);
        parent::__construct($message, $code, $previous);
    }
}