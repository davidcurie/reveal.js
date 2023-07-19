---
title: "Quantum Applications"
author: David Curie
standalone: true
revealjs-url: "../.."
mathjax: true
output-format: revealjs
slideNumber: true
---

# Motivation

> There's plenty of room at the bottom.
>
> -- Richard Feynman, 1959

## Quantum Supremacy

Desired goals:

- Powerful, efficient, and fast computation
- Secure communication

::: notes

Quantum supremacy
: Carry out tasks not possible or practical on a classical computer

:::

## {background-video="images/alice-bob-1.mov"}

## {background-image="images/alice-bob-2.png"}

## {background-video="images/alice-bob-3.mov"}

## RSA Encryption

$$
\textrm{Encrypted key} \propto k \times \textrm{Private key} \times \textrm{Public key}
$$

> - <mark>Security depends on how difficult it is to factor large prime numbers</mark>

::: notes
- 1999: RSA-512 took 8,400 MIPS years, or about 7 months
- 2020: RSA-250 (250 decimal digits, 829 bits) was brute-forced in 2,700 CPU years
- RSA-4096 is recommended standard today
:::

---

New attack vector:

- Store Now, Decrypt Later

Solutions:

- Tamper-proof protocols
- Make factoring _REALLY_ difficult

::: notes
- See Veritasium video for more details on latter part
- How Quantum Computers Break The Internet...Starting Now
- Ref: https://youtu.be/-UrdExQW0cs
:::

## {background-video="images/alice-bob-4.mov"}

:::notes
- Theoretical max throughput is 0.5 of what you send
- After allowing for extra redundancy checks and error correction, actual throughput is closer to 0.3
- Entangled sources would bring the theoretical throughput closer to 1
- Can already achieve this, but not for very far distances
:::

# Life at the bottom

## Decision Matrix {transition=none}

|                                  | I know how to get there | I don't know how to get there |
|----------------------------------|-------------------------|-------------------------------|
| **I know where I'm going**       |                         |                               |
| **I don't know where I'm going** |                         |                               |

## Decision Matrix {transition=none}

|                                  | I know how to get there | I don't know how to get there |
|----------------------------------|-------------------------|-------------------------------|
| **I know where I'm going**       |                         | Journey                       |
| **I don't know where I'm going** |                         |                               |

## Decision Matrix {transition=none}

|                                  | I know how to get there | I don't know how to get there |
|----------------------------------|-------------------------|-------------------------------|
| **I know where I'm going**       |                         | Journey                       |
| **I don't know where I'm going** | PhD                     |                               |

## Decision Matrix {transition=none}

|                                  | I know how to get there | I don't know how to get there |
|----------------------------------|-------------------------|-------------------------------|
| **I know where I'm going**       | Road trip               | Journey                       |
| **I don't know where I'm going** | PhD                     |                               |

## Decision Matrix {transition=none}

|                                  | I know how to get there | I don't know how to get there |
|----------------------------------|-------------------------|-------------------------------|
| **I know where I'm going**       | Road trip               | Journey                       |
| **I don't know where I'm going** | PhD                     | X                             |
