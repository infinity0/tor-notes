Composing Pluggable Transports
==============================

.. contents::

General strategy of this article: for both the client- and server-side PTs, we:

* model the concrete specification of the PT
* abstract this into a much simpler form, so that composition is easier to reason about
* derive, from first principles, a composition for this abstract model
* suggest some concrete options for implementing the abstract composition

Client Transport Plugin
+++++++++++++++++++++++

Model of a single PT (concrete)
-------------------------------

.. image:: pt_client_single_impl.svg

As described in the `Tor PT spec <https://gitweb.torproject.org/torspec.git/blob/HEAD:/pt-spec.txt>`_ the SOCKS connection to the client PT has three components:

* U - the TLS Tor protocol connection to the Bridge itself
* A - the address of the Bridge
* S - any metadata needed for the PT to function (e.g. a shared secret between the PTs on each side.)

We have `A[1]`, the address of the client PT itself, given on the `ClientTransportPlugin` line. This is an input to Tor. `A` and `S` are currently given on the `Bridge` line in torrc but in future *might* be dynamically obtained by Tor - so we don't model it as an input.

Notably, the output of the client PT is *unspecified*. Usually, it sends transformed traffic (combining U and S) directly to the PT on the Bridge at `A`, but more generally it could do anything (e.g. flashproxy contacts other services and *receives* incoming connections) as long as it somehow communicates with the Bridge at `A`.

Model of a single PT (abstract)
-------------------------------

.. image:: pt_client_single.svg

In our abstract model, we structurally split out semantically-separate sources of data. This gives us 2 components and 3 interfaces:

* The client PT with in-interface of (U, A, S) and out-interface of either U' sent to A, or unspecified "magic".
* Tor with out-interface of (U, A, S) sent to the client PT at A[1].

We now try to compose multiple PTs whilst retaining the relevant interfaces.

Composing many PTs (abstract)
-----------------------------

.. image:: pt_client_multi.svg

This is a composition that does all the "natural", "obvious" things that can be done from the single PT case. Of course, it is incomplete - not all the interfaces are connected up. In order to complete it, and suggest a concrete implementation, we must:

* pass `A[n]` to the PT at `A[n-1]`
* for each Bridge `A`, we now have `n` pieces of metadata `S[1..n]` to send to each client PT
* separate `U` and `A` so that `A` goes to the *last* PT in the chain, rather than both going to the first one.

One other vital thing is that each PT, except for the last, must now have a well-defined out-interface, of sending a single stream of data to the address so ordered by the previous component.

Composing many PTs (concrete) - option 1, chaining
--------------------------------------------------

.. image:: pt_client_multi_impl_chain.svg

This is an option that requires no new component, but many changes to existing components:

* each non-final PT must also implement a SOCKS server to send to the next PT.
* each non-final PT must be able to parse the incoming S as a collection of metadata, and process it so it's suitable for the next PT.
* Tor needs to be able to construct this combined metadata in the first place.

Actually the A[i] inputs aren't necessary if Tor is able to tell the PTs to listen on any port, then read this port from the managed-transport stdio protocol. (obfs-flash does this with flashproxy). TODO(infinity0): file a bug on trac.

Composing many PTs (concrete) - option 2, composition
-----------------------------------------------------

.. image:: pt_client_multi_impl_parent.svg

TODO

* don't need to change exising components
* need a precise way of combining S[i] metadata.

TODO: fix the diagram; the internal shims listen on their own addresses (and for the obfs-flash one below). This is another negative point, the explosion of addresses we have to listen on.

Composing many PTs (concrete) - option 2 simplified, obfs-flash
---------------------------------------------------------------

.. image:: pt_client_multi_impl_obfs-flash.svg

TODO

Server Transport Plugin
+++++++++++++++++++++++

TODO
