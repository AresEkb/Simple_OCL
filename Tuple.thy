(*  Title:       Simple OCL Semantics
    Author:      Denis Nikiforov, December 2018
    Maintainer:  Denis Nikiforov <denis.nikif at gmail.com>
    License:     LGPL
*)
section{* Tuples *}
theory Tuple
  imports Main Finite_Map_Ext Transitive_Closure_Ext
begin

subsection{* Definitions *}

abbreviation
  "subtuple f xm ym \<equiv> fmrel_on_fset (fmdom ym) f xm ym"

abbreviation
  "strict_subtuple f xm ym \<equiv> subtuple f xm ym \<and> xm \<noteq> ym"

(*** Helper Lemmas **********************************************************)

subsection{* Helper Lemmas *}

lemma fmrel_to_subtuple:
  "fmrel r xm ym \<Longrightarrow>
   subtuple r xm ym"
  apply (unfold fmrel_on_fset_fmrel_restrict)
  by blast

lemma subtuple_eq_fmrel_fmrestrict_fset:
  "subtuple r xm ym = fmrel r (fmrestrict_fset (fmdom ym) xm) ym"
  by (simp add: fmrel_on_fset_fmrel_restrict)

lemma subtuple_fmdom:
  "subtuple f xm ym \<Longrightarrow>
   subtuple g ym xm \<Longrightarrow>
   fmdom xm = fmdom ym"
  by (meson fmrel_on_fset_fmdom fset_eqI)

(*** Basic Properties *******************************************************)

subsection{* Basic Properties *}

lemma subtuple_refl:
  "(\<And>x. R x x) \<Longrightarrow> subtuple R xm xm"
  by (simp add: fmrel_on_fset_refl_strong)

lemma subtuple_mono [mono]:
  "(\<And>x y. x \<in> fmran' xm \<Longrightarrow> y \<in> fmran' ym \<Longrightarrow> f x y \<longrightarrow> g x y) \<Longrightarrow>
   subtuple f xm ym \<longrightarrow> subtuple g xm ym"
  apply (auto)
  apply (rule fmrel_on_fsetI)
  apply (drule_tac ?P="f" and ?m="xm" and ?n="ym" in fmrel_on_fsetD, simp)
  apply (erule option.rel_cases, simp)
  apply (auto simp add: option.rel_sel fmran'I)
  done

lemma strict_subtuple_mono [mono]:
  "(\<And>x y. x \<in> fmran' xm \<Longrightarrow> y \<in> fmran' ym \<Longrightarrow> f x y \<longrightarrow> g x y) \<Longrightarrow>
   strict_subtuple f xm ym \<longrightarrow> strict_subtuple g xm ym"
  using subtuple_mono by blast

lemma subtuple_antisym:
  "subtuple (\<lambda>x y. x = y \<or> f x y \<and> \<not> f y x) xm ym \<Longrightarrow>
   subtuple (\<lambda>x y. x = y \<or> f x y) ym xm \<Longrightarrow>
   xm = ym"
  apply (frule subtuple_fmdom, simp)
  apply (rule fmap_ext)
  apply (unfold subtuple_eq_fmrel_fmrestrict_fset)
  apply (erule_tac ?x="x" in fmrel_cases)
  apply force
  apply (erule_tac ?x="x" in fmrel_cases)
  apply force
  by (metis fmrestrict_fset_dom option.sel)

lemma strict_subtuple_antisym:
  "strict_subtuple (\<lambda>x y. x = y \<or> f x y \<and> \<not> f y x) xm ym \<Longrightarrow>
   strict_subtuple (\<lambda>x y. x = y \<or> f x y) ym xm \<Longrightarrow> False"
  by (auto simp add: subtuple_antisym)

lemma subtuple_acyclic:
  "acyclic_on (fmran' xm) P \<Longrightarrow>
   subtuple (\<lambda>x y. x = y \<or> P x y)\<^sup>+\<^sup>+ xm ym \<Longrightarrow>
   subtuple (\<lambda>x y. x = y \<or> P x y) ym xm \<Longrightarrow>
   xm = ym"
  apply (frule subtuple_fmdom, simp)
  apply (unfold fmrel_on_fset_fmrel_restrict, simp)
  apply (rule fmap_ext)
  apply (erule_tac ?x="x" in fmrel_cases)
  apply (metis fmrestrict_fset_dom)
  apply (erule_tac ?x="x" in fmrel_cases)
  apply (metis fmrestrict_fset_dom)
  by (metis fmran'I fmrestrict_fset_dom option.inject rtranclp_into_tranclp1)
(*
  by (smt fmap_ext fmran'I fmrel_cases fmrestrict_fset_dom option.simps(1)
          rtranclp_into_tranclp1 subtuple_eq_fmrel_fmrestrict_fset subtuple_fmdom)
*)

lemma strict_subtuple_trans:
  "acyclic_on (fmran' xm) P \<Longrightarrow>
   strict_subtuple (\<lambda>x y. x = y \<or> P x y)\<^sup>+\<^sup>+ xm ym \<Longrightarrow>
   strict_subtuple (\<lambda>x y. x = y \<or> P x y) ym zm \<Longrightarrow>
   strict_subtuple (\<lambda>x y. x = y \<or> P x y)\<^sup>+\<^sup>+ xm zm"
  apply auto
  apply (rule fmrel_on_fset_trans, auto)
  by (drule_tac ?ym="ym" in subtuple_acyclic; auto)

lemma subtuple_fmmerge2 [intro]:
  "(\<And>x y. x \<in> fmran' xm \<Longrightarrow> f x (g x y)) \<Longrightarrow>
   subtuple f xm (fmmerge g xm ym)"
  by (rule_tac ?S="fmdom ym" in fmrel_on_fsubset; auto)

(*** Transitive Closures ****************************************************)

subsection{* Transitive Closures *}

lemma trancl_to_subtuple:
  "(subtuple r)\<^sup>+\<^sup>+ xm ym \<Longrightarrow>
   subtuple r\<^sup>+\<^sup>+ xm ym"
  apply (induct rule: tranclp_induct)
  apply (metis subtuple_mono tranclp.r_into_trancl)
  by (rule fmrel_on_fset_trans, auto)

lemma rtrancl_to_subtuple:
  "(subtuple r)\<^sup>*\<^sup>* xm ym \<Longrightarrow>
   subtuple r\<^sup>*\<^sup>* xm ym"
  apply (induct rule: rtranclp_induct)
  apply (simp add: fmap.rel_refl_strong fmrel_to_subtuple)
  apply (rule fmrel_on_fset_trans; auto)
  done

lemma fmrel_to_subtuple_trancl:
  "(\<And>x. r x x) \<Longrightarrow>
   (fmrel r)\<^sup>+\<^sup>+ (fmrestrict_fset (fmdom ym) xm) ym \<Longrightarrow>
   (subtuple r)\<^sup>+\<^sup>+ xm ym"
  apply (frule trancl_to_fmrel)
  apply (rule_tac ?r="r" in fmrel_tranclp_induct, auto)
  apply (metis (no_types, lifting) fmrel_fmdom_eq
          subtuple_eq_fmrel_fmrestrict_fset tranclp.r_into_trancl)
  by (meson fmrel_to_subtuple tranclp.simps)

lemma subtuple_to_trancl:
  "(\<And>x. r x x) \<Longrightarrow>
   subtuple r\<^sup>+\<^sup>+ xm ym \<Longrightarrow>
   (subtuple r)\<^sup>+\<^sup>+ xm ym"
  apply (rule fmrel_to_subtuple_trancl)
  unfolding fmrel_on_fset_fmrel_restrict
  by (simp_all add: fmrel_to_trancl)

lemma subtuple_rtranclp_intro:
  assumes "bij_on_trancl R f"
      and "\<And>xm ym. R (f xm) (f ym) \<Longrightarrow> subtuple R xm ym"
      and "R\<^sup>*\<^sup>* (f xm) (f ym)"
    shows "subtuple R\<^sup>*\<^sup>* xm ym"
proof -
  have "(\<lambda>xm ym. R (f xm) (f ym))\<^sup>*\<^sup>* xm ym"
    apply (insert assms(1) assms(3))
    by (rule reflect_rtranclp; auto)
  hence "(subtuple R)\<^sup>*\<^sup>* xm ym" by (smt assms(2) mono_rtranclp)
  hence "subtuple R\<^sup>*\<^sup>* xm ym" by (rule rtrancl_to_subtuple)
  thus ?thesis by (simp)
qed

(*** Code Setup *************************************************************)

subsection{* Code Setup *}

abbreviation "subtuple_fun f xm ym \<equiv>
  fBall (fmdom ym) (\<lambda>x. rel_option f (fmlookup xm x) (fmlookup ym x))"

abbreviation "strict_subtuple_fun f xm ym \<equiv>
  subtuple_fun f xm ym \<and> xm \<noteq> ym"

lemma subtuple_fun_simp [code_abbrev, simp]:
  "subtuple_fun f xm ym = subtuple f xm ym"
  by (simp add: fmrel_on_fset_alt_def)

lemma strict_subtuple_fun_simp [code_abbrev, simp]:
  "strict_subtuple_fun f xm ym = strict_subtuple f xm ym"
  by simp

(*** Test Cases *************************************************************)

subsection{* Test Cases *}

definition "t1 \<equiv> fmupd (1::nat) (1::nat) (fmupd (2::nat) (2::nat) fmempty)"
definition "t2 \<equiv> fmupd (3::nat) (3::nat) (fmupd (1::nat) (1::nat) (fmupd (2::nat) (1::nat) fmempty))"
definition "t3 \<equiv> fmupd (3::nat) (4::nat) (fmupd (1::nat) (1::nat) (fmupd (2::nat) (1::nat) fmempty))"

value "subtuple (\<le>) t1 t1"
value "subtuple (\<le>) t1 t2"
value "subtuple (\<le>) t2 t1"
value "subtuple (\<le>) t2 t3"
value "subtuple (\<le>) t3 t2"
value "strict_subtuple (\<le>) t3 t2"

end
