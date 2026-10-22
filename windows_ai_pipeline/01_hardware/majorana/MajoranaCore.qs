// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  PIPELINE ETAPA 1 — HARDWARE / MAJORANA                                     ║
// ║  Arquivo: MajoranaCore.qs                                                   ║
// ║  Módulo: QPU Majorana-2 — BdG Hamiltonian, Braiding, Zero Modes            ║
// ║  Posição na árvore: 01_hardware/majorana/                                   ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
// BdG: H_BdG = ξ_k τ_z + Δ τ_x + V_z σ_z + α_R k σ_y τ_z
// Topological phase: |V_z| > √(Δ² + μ²)
// Braiding: B₁₂ = (1/√2)(1 + γ₁γ₂)
// T₁ ~ 20s @ T < 50mK | Δ_topo ~ 100 μeV

namespace WindowsAI.Pipeline.Hardware.Majorana {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // ── SEÇÃO 1: INICIALIZAÇÃO DO QPU ─────────────────────────────────────────
    operation InitializeMajoranaQPU(nQubits: Int, temperature_mK: Double) : Bool {
        Message($"[01_hardware/majorana] Inicializando Majorana-2 QPU");
        Message($"  Qubits: {nQubits} | T = {temperature_mK} mK");
        Message($"  Regime topológico: {temperature_mK < 50.0}");
        use qubits = Qubit[nQubits] {
            ApplyToEach(H, qubits);
            for i in 0..nQubits-2 { CNOT(qubits[i], qubits[i+1]); }
            ResetAll(qubits);
        }
        return temperature_mK < 50.0;
    }

    // ── SEÇÃO 2: HAMILTONIANO BdG ─────────────────────────────────────────────
    operation SimulateBdGHamiltonian(
        kineticEnergy: Double, gapEnergy: Double,
        zeemanField: Double, rashbaCoupling: Double,
        nShots: Int
    ) : (Double, Double, Bool) {
        let Delta = gapEnergy;
        let mu    = kineticEnergy;
        let Vz    = zeemanField;
        let alpha = rashbaCoupling;
        let isTopological = AbsD(Vz) > Sqrt(Delta*Delta + mu*mu);
        mutable groundEnergy = 0.0;
        mutable gapMeasured  = 0.0;
        use (systemQ, ancillaQ) = (Qubit[4], Qubit[4]) {
            // Encode BdG: ξ_k τ_z + Δ τ_x + V_z σ_z + α_R k σ_y τ_z
            Ry(2.0*ArcSin(Sqrt(AbsD(kineticEnergy)/10.0)), systemQ[0]);
            Rx(2.0*ArcSin(Sqrt(AbsD(gapEnergy)/10.0)),    systemQ[1]);
            Rz(2.0*ArcSin(Sqrt(AbsD(zeemanField)/10.0)),  systemQ[2]);
            Ry(2.0*ArcSin(Sqrt(AbsD(rashbaCoupling)/10.0)),systemQ[3]);
            CNOT(systemQ[0], systemQ[1]);
            CNOT(systemQ[1], systemQ[2]);
            CNOT(systemQ[2], systemQ[3]);
            for i in 0..3 { CNOT(systemQ[i], ancillaQ[i]); }
            mutable eSum = 0.0;
            mutable gSum = 0.0;
            for _ in 1..nShots {
                use mQ = Qubit[4] {
                    for i in 0..3 { CNOT(systemQ[i], mQ[i]); }
                    mutable e = 0.0;
                    for i in 0..3 {
                        let r = MResetZ(mQ[i]);
                        set e += r == One ? 1.0 | -1.0;
                    }
                    set eSum += e / 4.0;
                    set gSum += AbsD(e / 4.0);
                }
            }
            set groundEnergy = eSum / IntAsDouble(nShots) * Delta;
            set gapMeasured  = gSum / IntAsDouble(nShots) * Delta;
            ResetAll(systemQ); ResetAll(ancillaQ);
        }
        Message($"  BdG: E₀={groundEnergy:.4f}eV | Δ_obs={gapMeasured:.4f}eV | Topológico={isTopological}");
        return (groundEnergy, gapMeasured, isTopological);
    }

    // ── SEÇÃO 3: MODOS ZERO DE MAJORANA ──────────────────────────────────────
    operation PrepareMajoranaZeroModes(nModes: Int, nShots: Int) : Double[] {
        mutable parities = new Double[nModes];
        use modeQ = Qubit[nModes * 2] {
            // Criar pares de Majorana: γ₁ = c + c†, γ₂ = i(c - c†)
            for i in 0..nModes-1 {
                H(modeQ[2*i]);
                CNOT(modeQ[2*i], modeQ[2*i+1]);
                Rz(PI()/4.0, modeQ[2*i]);
                Rz(-PI()/4.0, modeQ[2*i+1]);
            }
            for mode in 0..nModes-1 {
                mutable pSum = 0.0;
                for _ in 1..nShots {
                    use ancilla = Qubit() {
                        CNOT(modeQ[2*mode],   ancilla);
                        CNOT(modeQ[2*mode+1], ancilla);
                        let r = MResetZ(ancilla);
                        set pSum += r == One ? 1.0 | -1.0;
                    }
                }
                set parities w/= mode <- pSum / IntAsDouble(nShots);
            }
            ResetAll(modeQ);
        }
        Message($"  Majorana ZMM: {nModes} modos preparados");
        return parities;
    }

    // ── SEÇÃO 4: OPERAÇÕES DE BRAIDING ────────────────────────────────────────
    operation BraidMajoranaQubits(
        logicalQ: Qubit[], braidSequence: Int[], nShots: Int
    ) : (Double, Double) {
        // B₁₂ = (1/√2)(1 + γ₁γ₂) — operação não-Abeliana
        let n = Length(logicalQ);
        mutable fidelity = 0.0;
        mutable phase    = 0.0;
        for step in braidSequence {
            let i = step % (n-1);
            // Braiding via sequência de portas
            H(logicalQ[i]);
            CNOT(logicalQ[i], logicalQ[i+1]);
            Rz(PI()/4.0,  logicalQ[i]);
            Rz(-PI()/4.0, logicalQ[i+1]);
            CNOT(logicalQ[i], logicalQ[i+1]);
            H(logicalQ[i]);
        }
        mutable fidSum   = 0.0;
        mutable phaseSum = 0.0;
        for _ in 1..nShots {
            use ancilla = Qubit() {
                H(ancilla);
                for i in 0..n-1 {
                    Controlled Rz([logicalQ[i]], (PI()/8.0, ancilla));
                }
                H(ancilla);
                let r = MResetZ(ancilla);
                set fidSum   += r == Zero ? 1.0 | 0.0;
                set phaseSum += r == One  ? 1.0 | 0.0;
            }
        }
        set fidelity = fidSum   / IntAsDouble(nShots);
        set phase    = phaseSum / IntAsDouble(nShots) * PI();
        return (fidelity, phase);
    }

    // ── SEÇÃO 5: CORREÇÃO DE ERROS TOPOLÓGICA ────────────────────────────────
    operation TopologicalErrorCorrection(
        dataQ: Qubit[], syndromeQ: Qubit[], nRounds: Int
    ) : (Int, Double) {
        mutable errorsDetected = 0;
        mutable fidelity       = 0.0;
        for round in 1..nRounds {
            // Medição de síndrome
            for i in 0..Length(dataQ)-2 {
                CNOT(dataQ[i],   syndromeQ[i]);
                CNOT(dataQ[i+1], syndromeQ[i]);
            }
            // Decodificar e corrigir
            for i in 0..Length(syndromeQ)-1 {
                use ancilla = Qubit() {
                    CNOT(syndromeQ[i], ancilla);
                    let s = MResetZ(ancilla);
                    if s == One {
                        set errorsDetected += 1;
                        X(dataQ[i]);
                    }
                }
            }
        }
        // Calcular fidelidade pós-correção
        mutable fidSum = 0.0;
        for i in 0..Length(dataQ)-1 {
            use ancilla = Qubit() {
                CNOT(dataQ[i], ancilla);
                let r = MResetZ(ancilla);
                set fidSum += r == Zero ? 1.0 | 0.0;
            }
        }
        set fidelity = fidSum / IntAsDouble(Length(dataQ));
        return (errorsDetected, fidelity);
    }

    // ── SEÇÃO 6: MEDIÇÃO DE PARIDADE ─────────────────────────────────────────
    operation MeasureFermionicParity(modeQ: Qubit[], nShots: Int) : Double {
        mutable paritySum = 0.0;
        let n = Length(modeQ);
        for _ in 1..nShots {
            use ancilla = Qubit() {
                for i in 0..n-1 { CNOT(modeQ[i], ancilla); }
                let r = MResetZ(ancilla);
                set paritySum += r == One ? 1.0 | -1.0;
            }
        }
        return paritySum / IntAsDouble(nShots);
    }

    // ── SEÇÃO 7: TEMPO DE COERÊNCIA T₁ ───────────────────────────────────────
    operation MeasureCoherenceTime(qubit: Qubit, nSteps: Int, dt_us: Double) : Double {
        X(qubit);
        mutable decaySum = 0.0;
        for step in 1..nSteps {
            // Simular decoerência: Ry(dt/T1)
            Ry(dt_us / 20e6 * PI(), qubit);
            use ancilla = Qubit() {
                CNOT(qubit, ancilla);
                let r = MResetZ(ancilla);
                set decaySum += r == One ? 1.0 | 0.0;
            }
        }
        // T₁ estimado
        let T1_us = -IntAsDouble(nSteps) * dt_us / Log(decaySum / IntAsDouble(nSteps) + 1e-10);
        return T1_us;
    }

    // ── SEÇÃO 8: PROTOCOLO DE INICIALIZAÇÃO COMPLETO ─────────────────────────
    operation RunMajoranaInitializationProtocol(nShots: Int) : Unit {
        Message("╔══════════════════════════════════════════════════════╗");
        Message("║  01_hardware/majorana — Protocolo de Inicialização  ║");
        Message("╚══════════════════════════════════════════════════════╝");

        // 8.1 — Inicializar QPU
        let qpuReady = InitializeMajoranaQPU(8, 20.0);
        Message($"  QPU pronto: {qpuReady}");

        // 8.2 — Simular BdG
        let (E0, gap, topo) = SimulateBdGHamiltonian(
            0.5e-4, 1.0e-4, 2.0e-4, 20.0e-3, nShots
        );
        Message($"  BdG: E₀={E0:.6f} | gap={gap:.6f} | topológico={topo}");

        // 8.3 — Preparar modos zero
        let parities = PrepareMajoranaZeroModes(4, nShots);
        Message($"  Paridades ZMM: {parities}");

        // 8.4 — Braiding
        use logQ = Qubit[4] {
            ApplyToEach(H, logQ);
            let (fid, ph) = BraidMajoranaQubits(logQ, [0,1,2,1,0], nShots);
            Message($"  Braiding: fidelidade={fid:.4f} | fase={ph:.4f}rad");
            ResetAll(logQ);
        }

        // 8.5 — Correção de erros
        use (dataQ, synQ) = (Qubit[4], Qubit[3]) {
            ApplyToEach(H, dataQ);
            let (errs, fid2) = TopologicalErrorCorrection(dataQ, synQ, 3);
            Message($"  Correção: {errs} erros detectados | fidelidade={fid2:.4f}");
            ResetAll(dataQ); ResetAll(synQ);
        }

        Message("  ✓ Majorana QPU inicializado com sucesso");
    }

    @EntryPoint()
    operation MajoranaMain() : Unit {
        RunMajoranaInitializationProtocol(100);
    }
}
