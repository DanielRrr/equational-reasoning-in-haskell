Haskell で等式証明
==================
GHC 7.4.* の PolyKinds 拡張や DataKinds 拡張などを使って、Agda 流の等式証明を Haskell で試みた記録です。

前提知識
-------
Curry-Howard 同型対応というものがありまして、それによると **型** は **命題** と、**プログラム** は **証明** とそれぞれ同一視することが出来ます。例えば、関数合成

```haskell
(.) :: (b -> c) -> (a -> b) -> a -> c
(f . g) x = f (g x)
```

は、いわゆる三段論法[^1] に対応します。つまり、`(.)` の型は

>
> * B ならば C である
> * A ならば B である
> 
> ∴ A ならば C である

と云う命題を表していて、その実装がその命題の証明を与えていることになる訳なんです。

[^1]: 「三段論法」は三つの命題からなる推論全般のことを意味するので、これは特に「仮言三段論法」と呼ばれるものです。

まあ、Curry-Howard 同型対応に関しては、他にももっと良い資料がネットに沢山転がっているので詳しい説明は検索してみてください。要は、命題を証明する、ということが、ある型を持つプログラムを書く、ということと同じだよ！と云う話です。

これを応用することで、命題の証明をコンピュータにやらせたり、或いは証明の正当性をコンピュータに検証させたり、と云うことが出来るようになります[^2]。今回採り上げるのは、後者です。証明の正当性を検証してくれるような言語のことを、**定理証明支援系**(*Proof assistant*)と呼びます。

[^2]: だったら数学者はオマンマの喰い上げじゃん！？と云うような気がしますが、コンピュータで自動的に証明出来る命題の範囲は限られているのと、機械が理解出来るような証明を書くには、ギャップのない非常に精密なものを書く必要があったりとで、もう暫くは数学者の世の中が続くことでしょう。
