theory WFTest
  imports
    Main
    Transitive_Closure_Ext
begin

datatype type = Bool | Integer | Real | Any | Set type | Seq type | Col type

inductive subtype ("_ \<sqsubset> _" [65, 65] 65) where
  "Bool \<sqsubset> Any"
| "Integer \<sqsubset> Real"
| "Real \<sqsubset> Any"
| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Set \<tau> \<sqsubset> Set \<sigma>"
| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Seq \<tau> \<sqsubset> Seq \<sigma>"
| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Col \<tau> \<sqsubset> Col \<sigma>"
| "Set \<tau> \<sqsubset> Col \<tau>"
| "Seq \<tau> \<sqsubset> Col \<tau>"
(*| "Void \<sqsubset> Bool"
| "Void \<sqsubset> Integer"
| "Void \<sqsubset> Set Void"
| "Void \<sqsubset> Seq Void"*)

inductive_cases subtype_x_Bool[elim!]: "\<tau> \<sqsubset> Bool"
inductive_cases subtype_Bool_x[elim!]: "Bool \<sqsubset> \<sigma>"
inductive_cases subtype_x_Integer[elim!]: "\<tau> \<sqsubset> Integer"
inductive_cases subtype_Integer_x[elim!]: "Integer \<sqsubset> \<sigma>"
inductive_cases subtype_x_Real[elim!]: "\<tau> \<sqsubset> Real"
inductive_cases subtype_Real_x[elim!]: "Real \<sqsubset> \<sigma>"
inductive_cases subtype_x_Any[elim!]: "\<tau> \<sqsubset> Any"
inductive_cases subtype_Any_x[elim!]: "Any \<sqsubset> \<sigma>"
inductive_cases subtype_x_Set[elim!]: "\<tau> \<sqsubset> Set \<sigma>"
inductive_cases subtype_Set_x[elim!]: "Set \<tau> \<sqsubset> \<sigma>"
inductive_cases subtype_x_Seq[elim!]: "\<tau> \<sqsubset> Seq \<sigma>"
inductive_cases subtype_Seq_x[elim!]: "Seq \<tau> \<sqsubset> \<sigma>"
inductive_cases subtype_x_Col[elim!]: "\<tau> \<sqsubset> Col \<sigma>"
inductive_cases subtype_Col_x[elim!]: "Col \<tau> \<sqsubset> \<sigma>"

lemma trancl_subtype_Col_x [elim!]:
  "subtype\<^sup>+\<^sup>+ (Col x) y \<Longrightarrow> (\<exists>z. y = Col z \<Longrightarrow> P) \<Longrightarrow> P"
  by (induct rule: tranclp_induct; auto)

lemma trancl_subtype_Set_x [elim!]:
  "subtype\<^sup>+\<^sup>+ (Set x) y \<Longrightarrow> (\<exists>z. y = Set z \<Longrightarrow> P) \<Longrightarrow> (\<exists>z. y = Col z \<Longrightarrow> P) \<Longrightarrow> P"
  by (induct rule: tranclp_induct; blast)

lemma Set_functor:
  "functor_under_rel subtype Set"
  apply (auto simp add: functor_under_rel_def rel_limited_under_def)
  by (meson injI type.inject(1))

lemma Seq_functor:
  "functor_under_rel subtype Seq"
  apply (auto simp add: functor_under_rel_def rel_limited_under_def)
  by (meson injI type.inject(2))

lemma Col_functor:
  "functor_under_rel subtype Col"
  apply (auto simp add: functor_under_rel_def rel_limited_under_def)
  by (meson injI type.inject(3))

lemma Set_Col_natural:
  "natural_under_rel subtype Set Col"
  by (auto simp add: natural_under_rel_def Set_functor Col_functor subtype.intros(7))


lemma q83:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> x \<noteq> y \<Longrightarrow> subtype\<^sup>+\<^sup>+ x y"
  by (meson Set_Col_natural tranclp_fun_preserve1b)

lemma q84:
  "subtype\<^sup>+\<^sup>+ x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Set y)"
  by (simp add: subtype.intros(4) tranclp_fun_preserve_gen_2a)

lemma q84:
  "subtype\<^sup>+\<^sup>+ x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Col y)"


lemma q1:
  "subtype\<^sup>+\<^sup>+ (Col x) (Col y) \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Col y)"
  apply (rule_tac ?b="Col x" in tranclp_into_tranclp2)
  apply (simp add: subtype.intros(7))
  apply (simp)
  done

lemma q2:
  "subtype\<^sup>+\<^sup>+ (Set x) (Set y) \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Col y)"
  apply (rule_tac ?b="Set y" in tranclp.trancl_into_trancl)
  apply (simp)
  apply (simp add: subtype.intros(7))
  done

lemma q3:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> x \<noteq> y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Col x) (Col y)"
  apply (erule converse_tranclpE)
  apply blast

lemma q4:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> x \<noteq> y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Set y)"


lemma q4:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> x \<noteq> y \<Longrightarrow> subtype\<^sup>+\<^sup>+ x y"

lemma q:
  "subtype\<^sup>+\<^sup>+ x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Col y)"
  apply (rule_tac ?b="Col x" in tranclp_into_tranclp2)
  apply (simp add: subtype.intros(7))
  by (simp add: subtype.intros(6) tranclp_fun_preserve_gen_2a)



lemma Set_not_less_Seq:
  "subtype\<^sup>+\<^sup>+ (Set x) (Seq y) \<Longrightarrow> False"

lemma subtype_implies_trancl_subtype:
  assumes as: "subtype\<^sup>+\<^sup>+ (Set x) (Seq y) \<Longrightarrow>
               (\<lambda>x y. subtype (Set x) (Seq y))\<^sup>+\<^sup>+ x y"
    shows "(subtype (Set x) (Seq y) \<Longrightarrow> P) \<Longrightarrow>
           subtype\<^sup>+\<^sup>+ (Set x) (Seq y) \<Longrightarrow> P"
  using assms tranclpD by fastforce

lemma q11:
  "subtype (Set x) y \<Longrightarrow> \<exists>z. y = Set z \<or> y = Col z"
  by auto

lemma q12:
  "subtype (Col x) y \<Longrightarrow> \<exists>z. y = Col z"
  by auto

lemma q13:
  "subtype x (Seq y) \<Longrightarrow> \<exists>z. x = Seq z"
  by auto

lemma q21:
  "subtype\<^sup>+\<^sup>+ (Set x) y \<Longrightarrow> (\<lambda>x y. subtype (Set x) y)\<^sup>+\<^sup>+ x y"

lemma q21:
  "subtype\<^sup>+\<^sup>+ (Set x) y \<Longrightarrow> \<exists>z. y = Set z \<or> y = Col z"

lemma q:
  "subtype\<^sup>+\<^sup>+ (Set xa) y \<Longrightarrow>
   subtype\<^sup>+\<^sup>+ y (Seq xb) \<Longrightarrow>
   rel_limited_under subtype (range Set) \<Longrightarrow>
   rel_limited_under subtype (range Seq) \<Longrightarrow>
   y \<notin> range Set \<Longrightarrow>
   y \<notin> range Seq \<Longrightarrow>
   (\<lambda>x x'. Set x \<sqsubset> Seq x')\<^sup>+\<^sup>+ (the_inv Set (Set xa)) (the_inv Seq (Seq xb))"


lemma q:
  "subtype\<^sup>+\<^sup>+ x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Col y)"
  apply (rule_tac ?b="Col x" in tranclp_into_tranclp2)
  apply (simp add: subtype.intros(7))
  by (simp add: subtype.intros(6) tranclp_fun_preserve_gen_2a)

lemma q21:
  "Set x \<sqsubset> Col y \<Longrightarrow> x = y"
  by blast

lemma q22:
  "Set x \<sqsubset> y \<Longrightarrow> (\<And>z. y = Set z \<Longrightarrow> x \<sqsubset> z \<Longrightarrow> P) \<Longrightarrow> (y = Col x \<Longrightarrow> P) \<Longrightarrow> P"

lemma q23:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> (subtype (Set x) (Col x) \<Longrightarrow> P) \<Longrightarrow> P"
  by (simp add: subtype.intros(7))

lemma q24:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> subtype (Set x) (Col x)"
  by (simp add: subtype.intros(7))

lemma q2:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> x \<noteq> y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Set y)"
  apply (erule tranclp.cases)
  apply auto[1]
  apply auto[1]
  apply (erule subtype_x_Col)
  
  apply (rule_tac ?b="Set y" in tranclp_into_tranclp2)
  apply (frule q24)
  apply (erule converse_tranclpE)
  apply (simp add: q21)
  apply (erule subtype_Set_x; auto)
(*
  apply (erule tranclp.cases)
  apply auto[1]
*)
lemma q2:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> (\<lambda>x y. subtype (Col x) (Col y))\<^sup>+\<^sup>+ x y"

lemma q2:
  "subtype\<^sup>+\<^sup>+ (Set x) (Col y) \<Longrightarrow> subtype (Set x) (Col x) \<and> (\<lambda>x y. subtype (Col x) (Col y))\<^sup>+\<^sup>+ x y"
  apply (erule converse_tranclpE)

lemma q:
  "subtype\<^sup>+\<^sup>+ (Set xa) y \<Longrightarrow>
   subtype\<^sup>+\<^sup>+ y (Col xb) \<Longrightarrow>
   rel_limited_under subtype (range Set) \<Longrightarrow>
   rel_limited_under subtype (range Col) \<Longrightarrow>
   y \<notin> range Set \<Longrightarrow>
   y \<notin> range Col \<Longrightarrow>
   (\<lambda>x x'. Set x \<sqsubset> Col x')\<^sup>+\<^sup>+ xa xb"

  thm tranclp_fun_preserve_gen_1
lemma q:
       "subtype\<^sup>+\<^sup>+ (Set xa) y \<Longrightarrow>
       subtype\<^sup>+\<^sup>+ y (Set xb) \<Longrightarrow>
   inj Set \<Longrightarrow>
       y \<notin> range Set \<Longrightarrow>
   rel_limited_under subtype (range Set) \<Longrightarrow>
       (\<lambda>x x'. Set x \<sqsubset> Set x')\<^sup>+\<^sup>+
        (the_inv Set (Set xa))
        (the_inv Set (Set xb))
"
  apply (unfold the_inv_f_f)
  apply (metis (mono_tags) tranclp_fun_preserve_gen_1 tranclp_trans)
(*
  apply (simp add: tranclp_fun_preserve_gen_1)
*)

(*
       subtype\<^sup>+\<^sup>+ (Set xa) y \<Longrightarrow>
       subtype\<^sup>+\<^sup>+ y (Set xb) \<Longrightarrow>
       P =
       (\<lambda>y y'.
           y \<in> range Set \<longrightarrow>
           y' \<in> range Set \<longrightarrow>
           (\<lambda>x x'. Set x \<sqsubset> Set x')\<^sup>+\<^sup>+
            (the_inv Set y) (the_inv Set y')) \<Longrightarrow>
       FR = range Set \<Longrightarrow>
       GR = range Col \<Longrightarrow>
       rel_limited_under subtype (range Set) \<Longrightarrow>
       rel_limited_under subtype (range Col) \<Longrightarrow>
       R = subtype \<Longrightarrow>
       f = Set \<Longrightarrow>
       g = Col \<Longrightarrow>
       f'' =
       restrict (the_inv Set) (range Set) \<Longrightarrow>
       f' = the_inv Set \<Longrightarrow>
       g'' =
       restrict (the_inv Col) (range Col) \<Longrightarrow>
       g' = the_inv Col \<Longrightarrow>
       inj Set \<Longrightarrow>
       y \<notin> range Set \<Longrightarrow>
       (\<lambda>x x'. Set x \<sqsubset> Set x')\<^sup>+\<^sup>+
        (the_inv Set (Set xa))
        (the_inv Set (Set xb))
*)

lemma q:
  "\<And>x y z. subtype\<^sup>+\<^sup>+ (Set x) y \<Longrightarrow> P x y' \<Longrightarrow> subtype\<^sup>+\<^sup>+ y (Col z) \<Longrightarrow> P y' z \<Longrightarrow> P x z"

lemma z11:
  "x \<in> range Set \<Longrightarrow> \<exists>z. x = Set z
   the_inv Set x = x"
  by auto

lemma z11:
  "    y \<sqsubset> y' \<Longrightarrow>
       inj Set \<Longrightarrow>
       inj Col \<Longrightarrow>
       bij_betw Set UNIV (range Set) \<Longrightarrow>
       bij_betw Col UNIV (range Col) \<Longrightarrow>
       (\<And>x. Set x \<sqsubset> Col x) \<Longrightarrow>
       (y \<in> range Set \<and> y' \<in> range Set \<longrightarrow>
        subtype\<^sup>+\<^sup>+ (the_inv Set y) (the_inv Set y')) (*\<and>
       (y \<in> range Set \<and> y' \<in> range Col \<longrightarrow>
        subtype\<^sup>+\<^sup>+ (the_inv Set y) (the_inv Col y')) \<and>
       (y \<in> range Col \<and> y' \<in> range Set \<longrightarrow>
        subtype\<^sup>+\<^sup>+ (the_inv Col y) (the_inv Set y')) \<and>
       (y \<in> range Col \<and> y' \<in> range Col \<longrightarrow>
        subtype\<^sup>+\<^sup>+ (the_inv Col y) (the_inv Col y'))*)"
  apply (auto)
  by (simp add: the_inv_f_f)
(*
lemma z12:
  "    y \<sqsubset> y' \<Longrightarrow>
       inj Set \<Longrightarrow>
       inj Col \<Longrightarrow>
       bij_betw Set UNIV (range Set) \<Longrightarrow>
       bij_betw Col UNIV (range Col) \<Longrightarrow>
       (\<And>x. Set x \<sqsubset> Col x) \<Longrightarrow>
       (y \<in> range Set \<and> y' \<in> range Set \<longrightarrow> subtype\<^sup>+\<^sup>+ (the_inv Set y) (the_inv Set y')) \<and>
       (y \<in> range Set \<and> y' \<in> range Col \<longrightarrow> subtype\<^sup>+\<^sup>+ (the_inv Set y) (the_inv Col y')) \<and>
       (y \<in> range Col \<longrightarrow> y' \<notin> range Set) \<and>
       (y \<in> range Col \<and> y' \<in> range Col \<longrightarrow> subtype\<^sup>+\<^sup>+ (the_inv Col y) (the_inv Col y'))"
  apply (auto)
  apply (simp add: the_inv_f_f)
  apply (simp add: the_inv_f_f)
  by (simp add: the_inv_f_f)
*)



lemma q81:
  "subtype (Seq x) (Set y) \<Longrightarrow> False"
  using subtype.cases by blast

lemma q82:
  "subtype\<^sup>+\<^sup>+ (Seq x) (Set y) \<Longrightarrow> False"

datatype t = A | B | C t | D t | E t

inductive R where
  "R A B"
| "R x y \<Longrightarrow> R (C x) (C y)"
| "R x y \<Longrightarrow> R (D x) (D y)"
| "R x y \<Longrightarrow> R (E x) (E y)"
| "R (C x) (E x)"
| "R (D x) (E x)"

thm R.simps t.distinct(11) t.distinct(3) t.distinct(5) t.distinct(7) t.distinct(9) tranclp_trans_induct

lemma q:
  "    R\<^sup>+\<^sup>+ (f xa) y \<Longrightarrow>
       R\<^sup>+\<^sup>+ y (g xb) \<Longrightarrow>
       rel_limited_under R (range f) \<Longrightarrow>
       rel_limited_under R (range g) \<Longrightarrow>
       y \<notin> range f \<Longrightarrow>
       y \<notin> range g \<Longrightarrow>
       (\<lambda>x x'. R (f x) (g x'))\<^sup>+\<^sup>+ (f'' (f xa)) (g'' (g xb))"


lemma tranclp_fun_preserve_gen_1:
  fixes f:: "'a \<Rightarrow> 'b"
    and g:: "'a \<Rightarrow> 'b"
    and x x'::'a
  assumes as_f: "inj f"
      and as_g: "inj g"
      and as_Rf: "rel_limited_under R (range f)"
      and as_Rg: "rel_limited_under R (range g)"
      and as_fg: "range f \<inter> range g = {}"
      and prem: "R\<^sup>+\<^sup>+ (f x) (g x')"
  shows "(\<lambda>x x'. R (f x) (g x'))\<^sup>+\<^sup>+ x x'"
proof -
  obtain f' where f': "f' = the_inv_into UNIV f" by auto
  obtain f'' where f'': "f'' = restrict f' (range f)" by auto
  obtain g' where g': "g' = the_inv_into UNIV g" by auto
  obtain g'' where g'': "g'' = restrict g' (range g)" by auto
  obtain B where B: "B = range f" by auto
  obtain C where C: "C = range g" by auto
  obtain P where P: "P = (\<lambda>y y'. y \<in> B \<longrightarrow> y' \<in> C \<longrightarrow> (\<lambda> x x'. R (f x) (g x'))\<^sup>+\<^sup>+ (f'' y) (g'' y'))" by auto
  from B as_f have as_f2: "bij_betw f UNIV B" by (simp add: bij_betw_imageI)
  from C as_g have as_g2: "bij_betw g UNIV C" by (simp add: bij_betw_imageI)
  from prem have major: "R\<^sup>+\<^sup>+ (f x) (g x')" by blast
  from P f' f'' g' g'' as_f2 as_g2 have cases_1: "\<And>y y'. R y y' \<Longrightarrow> P y y'"
    by (metis (no_types, lifting) bij_betw_imp_inj_on bij_betw_imp_surj_on 
        f_the_inv_into_f restrict_apply' tranclp.r_into_trancl)
  from P B C as_Rf as_Rg have cases_2:
    "\<And>x y z. R\<^sup>+\<^sup>+ x y \<Longrightarrow> P x y \<Longrightarrow> R\<^sup>+\<^sup>+ y z \<Longrightarrow> P y z \<Longrightarrow> P x z"
    apply (auto)
(*    by (smt cases_1 rel_limited_under_def rtranclp_induct tranclp_into_rtranclp tranclp_rtranclp_tranclp)*)
(*    by (meson rel_limited_under_def tranclp_trans)*)
  from tranclp_trans_induct major cases_1 cases_2 have inv_conc: "P (f x) (f x')" by smt
  with P B as_f g gr show ?thesis
    by (simp add: the_inv_f_f)
qed

lemma a11:
  "R (C x) (D y) \<Longrightarrow> False"
  using R.simps by blast

lemma a11:
  "((\<lambda>x y. R (C x) (D y))\<^sup>+\<^sup>+ x y \<Longrightarrow> False) \<Longrightarrow> R\<^sup>+\<^sup>+ (C x) (D y) \<Longrightarrow> False"


lemma q:
  "R\<^sup>+\<^sup>+ x y \<Longrightarrow> x = C a \<Longrightarrow> y = D b \<Longrightarrow> False"
  apply (induct rule: tranclp.induct)
(*
  by (metis R.cases R.intros(2) R.intros(3) R.simps rtranclp.rtrancl_refl t.distinct(11) t.distinct(3) t.distinct(5) t.distinct(7) t.distinct(9) tranclp.simps tranclpD tranclp_trans_induct)
*)
lemma q:
  "R\<^sup>+\<^sup>+ (C x) (D y) \<Longrightarrow> False"
(*  apply (unfold R.simps)*)
(*
  by (metis R.simps t.distinct(11) t.distinct(3) t.distinct(5) t.distinct(7) t.distinct(9) tranclp_trans_induct)
*)
(*
lemma tranclp_fun_preserve_gen_11:
  assumes as_f: "inj Set"
    and as_R: "rel_limited_under subtype (range Set)"
    and prem: "subtype\<^sup>+\<^sup>+ (Set x) (Set x')"
  shows "subtype\<^sup>+\<^sup>+ x x'"
proof -
  obtain g where g: "g = the_inv_into UNIV Set" by auto
  obtain gr where gr: "gr = restrict g (range Set)" by auto
  obtain B where B: "B = range Set" by auto
  obtain P where P: "P = (\<lambda>y y'. y \<in> B \<longrightarrow> y' \<in> B \<longrightarrow> subtype\<^sup>+\<^sup>+ (gr y) (gr y'))" by auto
  from B as_f have as_f2: "bij_betw Set UNIV B" by (simp add: bij_betw_imageI)
  from prem have major: "subtype\<^sup>+\<^sup>+ (Set x) (Set x')" by blast
  from B as_f gr P as_f2 g have cases_1: "\<And>y y'. subtype y y' \<Longrightarrow> P y y'"
    apply (auto simp add: P)
    using subtype.cases the_inv_f_f by fastforce
  from P B as_R have cases_2:
    "\<And>x y z. subtype\<^sup>+\<^sup>+ x y \<Longrightarrow> P x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ y z \<Longrightarrow> P y z \<Longrightarrow> P x z"
    by (smt cases_1 rel_limited_under_def rtranclp_induct tranclp_into_rtranclp tranclp_rtranclp_tranclp)
  from tranclp_trans_induct major cases_1 cases_2 have inv_conc: "P (Set x) (Set x')" by smt
  with P B as_f g gr show ?thesis
    by (simp add: the_inv_f_f)
qed
*)



(*
lemma q75:
  "inj Set \<Longrightarrow>
   rel_limited_under subtype (range Set) \<Longrightarrow>
   subtype\<^sup>+\<^sup>+ (Set \<tau>) (Set \<sigma>) \<Longrightarrow> subtype\<^sup>+\<^sup>+ \<tau> \<sigma>"
  apply (simp add: tranclp_fun_preserve_gen_1a)
*)
(*
lemma tranclp_fun_preserve_gen_22:
  assumes prem: "subtype\<^sup>+\<^sup>+ x x'"
  shows "subtype\<^sup>+\<^sup>+ (Set x) (Set x')"
proof -
  obtain P where P: "P = (\<lambda>x x'. (\<lambda>y y'. subtype y y')\<^sup>+\<^sup>+ (Set x) (Set x'))" by auto
  obtain r where r: "r = (\<lambda>x x'. subtype (Set x) (Set x'))" by auto
  from prem r have major: "r\<^sup>+\<^sup>+ x x'"
    by (smt subtype.intros(4) tranclp.r_into_trancl tranclp_trans tranclp_trans_induct)
  from P r have cases_1: "\<And>y y'. r y y' \<Longrightarrow> P y y'" by simp
  from P have cases_2: "\<And>x y z. r\<^sup>+\<^sup>+ x y \<Longrightarrow> P x y \<Longrightarrow> r\<^sup>+\<^sup>+ y z \<Longrightarrow> P y z \<Longrightarrow> P x z" by auto
  from tranclp_trans_induct major cases_1 cases_2 have inv_conc: "P x x'" by smt
  with P show ?thesis by simp
qed
*)
(*inductive_cases direct_simple_subtype_x_Void[elim!]: "\<tau> \<sqsubset> Void"
inductive_cases direct_simple_subtype_Void_x[elim!]: "Void \<sqsubset> \<sigma>"*)

fun subtype_fun where
  "subtype_fun Bool Any = True"
| "subtype_fun Bool _ = False"
| "subtype_fun Integer Real = True"
| "subtype_fun Integer Any = True"
| "subtype_fun Integer _ = False"
| "subtype_fun Real Any = True"
| "subtype_fun Real _ = False"
| "subtype_fun (Set \<tau>) (Set \<sigma>) = subtype_fun \<tau> \<sigma>"
| "subtype_fun (Set \<tau>) (Col \<sigma>) = (\<tau> = \<sigma>)"
| "subtype_fun (Set \<tau>) _ = False"
| "subtype_fun (Seq \<tau>) (Seq \<sigma>) = subtype_fun \<tau> \<sigma>"
| "subtype_fun (Seq \<tau>) (Col \<sigma>) = (\<tau> = \<sigma>)"
| "subtype_fun (Seq \<tau>) _ = False"
| "subtype_fun (Col \<tau>) (Col \<sigma>) = subtype_fun \<tau> \<sigma>"
| "subtype_fun (Col \<tau>) _ = False"
| "subtype_fun Any _ = False"

print_theorems

lemma q31:
  "rel_limited_under subtype (range Set)"
  apply (simp add: rel_limited_under_def)
  by auto

lemma q32:
  "inj Set"
  by (simp add: inj_def)

lemma q41:
  "subtype\<^sup>+\<^sup>+ (Set x) (Set y) \<Longrightarrow> (\<lambda>x y. subtype (Set x) (Set y))\<^sup>+\<^sup>+ x y"
  by (simp add: q31 q32 tranclp_fun_preserve_gen_1)

lemma q42:
  "(\<lambda>x y. subtype (Set x) (Set y))\<^sup>+\<^sup>+ x y \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set x) (Set y)"
  by (simp add: tranclp_fun_preserve_gen_2)
(*
lemma q75:
  "subtype\<^sup>+\<^sup>+ \<tau> \<sigma> \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set \<tau>) (Set \<sigma>)"

lemma q76:
  "subtype\<^sup>+\<^sup>+ (Set \<tau>) (Set \<sigma>) \<Longrightarrow> subtype\<^sup>+\<^sup>+ \<tau> \<sigma>"
  apply (induct rule: tranclp_induct)
*)

lemma subtype_implies_fun:
  "subtype \<tau> \<sigma> \<Longrightarrow> subtype_fun \<tau> \<sigma>"
  by (induct rule: subtype.induct; simp)

lemma trancl_subtype_eq_fun2:
  "subtype_fun \<tau> \<sigma> \<Longrightarrow> subtype\<^sup>+\<^sup>+ \<tau> \<sigma>"
  apply (induct rule: subtype_fun.induct; simp)
  apply (simp add: subtype.intros tranclp.r_into_trancl)
  apply (simp add: subtype.intros tranclp.r_into_trancl)
  using subtype.intros apply auto[1]
  apply (simp add: subtype.intros tranclp.r_into_trancl)
  apply (simp add: subtype.intros(4) tranclp_fun_preserve_gen_2a)
  apply (simp add: subtype.intros tranclp.r_into_trancl)
  apply (simp add: subtype.intros(5) tranclp_fun_preserve_gen_2a)
  apply (simp add: subtype.intros tranclp.r_into_trancl)
  apply (simp add: subtype.intros(6) tranclp_fun_preserve_gen_2a)
  done

lemma q61:
  "subtype_fun \<tau> (Set \<sigma>) \<Longrightarrow> \<exists>\<rho>. \<tau> = Set \<rho> \<and> subtype\<^sup>+\<^sup>+ \<rho> \<sigma>"
  by (erule subtype_fun.elims; auto simp add: trancl_subtype_eq_fun2)

thm rtranclp_into_tranclp2
(*
lemma q62:
  "subtype\<^sup>+\<^sup>+ \<rho> \<sigma> \<Longrightarrow> \<tau> = Set \<rho> \<Longrightarrow> subtype_fun \<tau> (Set \<sigma>)"
  apply (drule tranclpD)
  by (simp add: subtype_implies_fun)

lemma q63:
  "\<exists>\<rho>. \<tau> = Set \<rho> \<and> subtype \<rho> \<sigma> \<Longrightarrow> subtype_fun \<tau> (Set \<sigma>)"
  using q62 by blast
*)
thm Nitpick.rtranclp_unfold tranclpD

lemma q82:
  "subtype\<^sup>+\<^sup>+ (Seq x) (Set y) \<Longrightarrow> False"

lemma q71:
  "subtype\<^sup>+\<^sup>+ \<tau> (Set x) \<Longrightarrow> \<exists>\<rho>. \<tau> = Set \<rho>"
  apply (induct arbitrary: )
  apply (metis converse_rtranclpE direct_simple_subtype_Any_x direct_simple_subtype_Bool_x tranclpD type.simps(35))
  apply (metis converse_rtranclpE direct_simple_subtype_Any_x direct_simple_subtype_Integer_x direct_simple_subtype_Real_x subtype.intros(7) tranclpD type.simps(28))
  apply (metis converse_rtranclpE direct_simple_subtype_Any_x direct_simple_subtype_Real_x tranclpD type.simps(35))
  apply (meson direct_simple_subtype_Any_x tranclpD)
  apply simp

(*
  by (metis (no_types, hide_lams) Nitpick.rtranclp_unfold direct_simple_subtype_Any_x direct_simple_subtype_Integer_x subtype.simps tranclpD type.distinct(17) type.distinct(19))
*)
(*
lemma q72:
  "subtype\<^sup>+\<^sup>+ \<tau> (Set x) \<Longrightarrow> (\<exists>\<rho>. \<tau> = Set \<rho> \<Longrightarrow> P) \<Longrightarrow> P"
  by (simp add: q71)
*)
lemma q73:
  "subtype_fun (Set \<tau>) \<sigma> \<Longrightarrow>
   subtype\<^sup>+\<^sup>+ (Set \<tau>) \<sigma>"
  by (simp add: trancl_subtype_eq_fun2)

lemma q74:
  "subtype\<^sup>+\<^sup>+ \<tau> \<sigma> \<Longrightarrow> (\<lambda>x y. subtype (Set x) (Set y))\<^sup>+\<^sup>+ \<tau> \<sigma>"
  by (smt subtype.intros(4) tranclp.r_into_trancl tranclp_trans tranclp_trans_induct)

lemma q75:
  "subtype\<^sup>+\<^sup>+ (Set \<tau>) (Set \<sigma>) \<Longrightarrow> subtype\<^sup>+\<^sup>+ \<tau> \<sigma>"


lemma trancl_subtype_eq_fun1:
  "subtype\<^sup>+\<^sup>+ \<tau> \<sigma> \<Longrightarrow> subtype_fun \<tau> \<sigma>"
  apply (induct arbitrary: \<tau>)
  using tranclp.cases apply fastforce
  using tranclp.cases apply fastforce
  apply (erule tranclp.cases)
  apply auto[1]
  using tranclp.cases apply fastforce
  apply (erule tranclp.cases)
  apply auto[1]
  apply (metis direct_simple_subtype_x_Any direct_simple_subtype_x_Bool direct_simple_subtype_x_Integer direct_simple_subtype_x_Real subtype_fun.simps(9) tranclp.cases)

  apply (smt direct_subtype_x_Set injD q31 q32 q72 subtype_fun.simps(22) tranclp_fun_preserve_gen_1a)


(*
  apply (metis direct_simple_subtype_x_Integer direct_simple_subtype_x_Real subtype_implies_fun tranclp.cases)
*)
(*
  apply (induct arbitrary: \<tau>)
  using tranclp.cases apply fastforce
  using tranclp.cases apply fastforce
  apply (metis direct_simple_subtype_x_Integer direct_simple_subtype_x_Real subtype_fun.simps(6) tranclp.cases)
  apply (metis direct_simple_subtype_x_Any direct_simple_subtype_x_Bool direct_simple_subtype_x_Integer direct_simple_subtype_x_Real subtype_fun.simps(1) subtype_fun.simps(11) subtype_fun.simps(7) tranclp.cases)
  using q31 q32 q71 subtype_fun.simps(16) tranclp_fun_preserve_gen_11 by blast
*)

lemma q22:
  "Set \<tau> \<sqsubset> Set \<sigma> \<Longrightarrow> \<tau> \<sqsubset> \<sigma>"
  by auto

lemma q1:
  "x \<sqsubset> y \<Longrightarrow> y \<sqsubset> x \<Longrightarrow> x = y"
  apply (induct rule: subtype.induct; erule subtype.cases; blast)
  done

lemma q2:
  "x \<sqsubset> y \<Longrightarrow> \<not> y \<sqsubset> x"
  apply (induct rule: subtype.induct; auto)
  done

lemma q3:
  "x \<sqsubset> y \<Longrightarrow> y \<sqsubset> z \<Longrightarrow> \<not> z \<sqsubset> x"
  apply (induct arbitrary: z rule: subtype.induct; auto)
  done

lemma q4:
  "x \<sqsubset> y \<Longrightarrow> y \<sqsubset> z \<Longrightarrow> z \<sqsubset> u \<Longrightarrow> \<not> u \<sqsubset> x"
  apply (induct arbitrary: z u rule: subtype.induct; auto)
  done

lemma q5:
  "x \<sqsubset> y \<Longrightarrow> y \<sqsubset> z \<Longrightarrow> z \<sqsubset> u \<Longrightarrow> u \<sqsubset> v \<Longrightarrow> \<not> v \<sqsubset> x"
  apply (induct arbitrary: z u v rule: subtype.induct; auto)
  done

lemma q51:
  "(subtype\<^sup>+\<^sup>+ \<tau> \<tau> \<Longrightarrow> P) \<Longrightarrow> subtype\<^sup>+\<^sup>+ (Set \<tau>) (Set \<tau>) \<Longrightarrow> P"

lemma q4:
  "subtype\<^sup>+\<^sup>+ \<tau> \<tau> \<Longrightarrow> False"
  apply (cases \<tau>)
  using tranclp.cases apply fastforce
  using tranclp.cases apply fastforce
  apply (metis converse_tranclpE direct_simple_subtype_Any_x direct_simple_subtype_Real_x)
  apply (meson direct_simple_subtype_Any_x tranclpD)
  apply (erule converse_tranclpE)
  using q2 apply blast
  apply (erule converse_tranclpE)
  using q2 apply blast
  apply (erule converse_tranclpE)
  using q3 apply blast
  apply (erule converse_tranclpE)
  using q4 apply blast
  apply (erule converse_tranclpE)
  using q5 apply blast

lemma q1:
  "(x, x) \<in> {(x, y). x \<sqsubset> y}\<^sup>+ \<Longrightarrow> False"
  apply (erule converse_tranclE)
  apply (induct rule: trancl_induct)

lemma q:
  "acyclicP subtype"
  apply (auto simp add: acyclic_def)
  apply (erule trancl_trans_induct)
  apply (erule tranclE)
  apply (simp)
  apply (erule subtype.cases; simp)








datatype simple_type = Bool | Nat | Integer | Real | Object nat | Any

(*derive linorder simple_type*)

inductive direct_simple_subtype ("_ \<sqsubset> _" [65, 65] 65) where
  "Bool \<sqsubset> Any"
| "Nat \<sqsubset> Integer"
| "Integer \<sqsubset> Real"
| "Real \<sqsubset> Any"
| "Object cls \<sqsubset> Any"

inductive_cases direct_simple_subtype_x_Bool[elim!]: "\<tau> \<sqsubset> Bool"
inductive_cases direct_simple_subtype_Bool_x[elim!]: "Bool \<sqsubset> \<sigma>"
inductive_cases direct_simple_subtype_x_Nat[elim!]: "\<tau> \<sqsubset> Nat"
inductive_cases direct_simple_subtype_Nat_x[elim!]: "Nat \<sqsubset> \<sigma>"
inductive_cases direct_simple_subtype_x_Integer[elim!]: "\<tau> \<sqsubset> Integer"
inductive_cases direct_simple_subtype_Integer_x[elim!]: "Integer \<sqsubset> \<sigma>"
inductive_cases direct_simple_subtype_x_Real[elim!]: "\<tau> \<sqsubset> Real"
inductive_cases direct_simple_subtype_Real_x[elim!]: "Real \<sqsubset> \<sigma>"
inductive_cases direct_simple_subtype_x_Object[elim!]: "\<tau> \<sqsubset> Object cls"
inductive_cases direct_simple_subtype_Objectn_x[elim!]: "Object cls \<sqsubset> \<sigma>"
inductive_cases direct_simple_subtype_x_Any[elim!]: "\<tau> \<sqsubset> Any"
inductive_cases direct_simple_subtype_Any_x[elim!]: "Any \<sqsubset> \<sigma>"

lemma acyclic_direct_simple_subtype:
  "acyclicP direct_simple_subtype"
  apply (auto simp add: acyclic_def)
  apply (erule tranclE)
  using direct_simple_subtype.cases apply blast
  apply (erule tranclE)
  using direct_simple_subtype.cases apply blast
  apply (erule tranclE)
  using direct_simple_subtype.cases apply blast
  apply (erule tranclE)
  using direct_simple_subtype.cases apply blast
  using direct_simple_subtype.cases apply blast
  done


datatype type = Void | Single simple_type | Set type | Seq type | Col type | Super

(*derive linorder type*)

definition "min_simple_type \<tau> \<equiv> \<nexists>\<sigma>. \<sigma> \<sqsubset> \<tau>"

lemma min_simple_type_code [code]:
  "min_simple_type \<tau> \<longleftrightarrow>
   \<tau> = Bool \<or> \<tau> = Nat \<or> (case \<tau> of Object _ \<Rightarrow> True | _ \<Rightarrow> False)"
  apply (simp add: min_simple_type_def)
  apply (rule iffI)
  apply (cases \<tau>; simp add: direct_simple_subtype.simps)
  apply auto[1]
  using direct_simple_subtype.simps by force

inductive direct_subtype ("_ \<prec> _" [65, 65] 65) where
  "min_simple_type \<tau> \<Longrightarrow> Void \<prec> Single \<tau>"
| "\<tau> \<sqsubset> \<sigma> \<Longrightarrow> Single \<tau> \<prec> Single \<sigma>"
| "Void \<prec> Set Void"
| "Void \<prec> Seq Void"
| "\<tau> \<prec> \<sigma> \<Longrightarrow> Set \<tau> \<prec> Set \<sigma>"
| "\<tau> \<prec> \<sigma> \<Longrightarrow> Seq \<tau> \<prec> Seq \<sigma>"
| "\<tau> \<prec> \<sigma> \<Longrightarrow> Col \<tau> \<prec> Col \<sigma>"
| "Set \<tau> \<prec> Col \<tau>"
| "Seq \<tau> \<prec> Col \<tau>"
| "Single Any \<prec> Super"
| "Col Super \<prec> Super"

inductive_cases direct_subtype_x_Void[elim!]: "\<tau> \<prec> Void"
inductive_cases direct_subtype_Void_x[elim!]: "Void \<prec> \<sigma>"
inductive_cases direct_subtype_x_Single[elim!]: "\<tau> \<prec> Single \<sigma>"
inductive_cases direct_subtype_Single_x[elim!]: "Single \<tau> \<prec> \<sigma>"
inductive_cases direct_subtype_x_Set[elim!]: "\<tau> \<prec> Set \<sigma>"
inductive_cases direct_subtype_Set_x[elim!]: "Set \<tau> \<prec> \<sigma>"
inductive_cases direct_subtype_x_Seq[elim!]: "\<tau> \<prec> Seq \<sigma>"
inductive_cases direct_subtype_Seq_x[elim!]: "Seq \<tau> \<prec> \<sigma>"
inductive_cases direct_subtype_x_Col[elim!]: "\<tau> \<prec> Col \<sigma>"
inductive_cases direct_subtype_Col_x[elim!]: "Col \<tau> \<prec> \<sigma>"
inductive_cases direct_subtype_x_Super[elim!]: "\<tau> \<prec> Super"
inductive_cases direct_subtype_Super_x[elim!]: "Super \<prec> \<sigma>"

code_pred direct_subtype .

value "Set (Single Nat) \<prec> Set (Single Real)"

lemma acyclic_direct_subtype:
  "acyclicP direct_subtype"
  apply (auto simp add: acyclic_def)
  apply (erule tranclE)
  apply (simp)
  apply (erule direct_subtype.cases; simp)


end